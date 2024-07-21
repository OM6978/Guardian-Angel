import 'dart:convert';
// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:translator/translator.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roti_kapda_makan/Views/food.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  final String phone;
  final String language;
  // final String UserName;

  const HomePage({Key? key, required this.phone, required this.language})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  var uuid = Uuid();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = {};
  String _sessionToken = '123456';
  String filter_flag = "all";
  Uint8List? markerImage;
  bool _isSearching = false;
  List<dynamic> _placeList = []; // Your place list
  final SpeechToText _speech = SpeechToText();
  List<dynamic> _filteredPlaceList = [];
  bool _speechEnabled = false;
  void initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  bool isCurrentTimeGreaterThanMarkerTime(String snippet) {
    // Extract time and date from snippet
    List<String> dateTimeParts = snippet.split(' ');
    String timeString = dateTimeParts[0];
    String dateString = dateTimeParts[1];

    // Format current date and time
    DateTime currentTime = DateTime.now();
    DateFormat timeFormat = DateFormat('HH:mm');
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    // Parse and format marker date and time
    DateTime markerTime = timeFormat.parse(timeString);
    DateTime markerDate = dateFormat.parse(dateString);
    DateTime formattedMarkerDateTime = DateTime(
      markerDate.year,
      markerDate.month,
      markerDate.day,
      markerTime.hour,
      markerTime.minute,
    );

    // Compare current time with marker time
    return currentTime.isAfter(formattedMarkerDateTime);
  }
// Future<void> decodeBase64Image(String base64Image) async {
//   try {
//     File? _image;
//     // Decode the base64-encoded string to bytes
//     List<int> imageBytes = base64Decode(base64Image);

//     // Create a temporary file and write the bytes to it
//     final tempDir = await getTemporaryDirectory();
//     final tempFile = File('${tempDir.path}/temp_image.jpg');
//     await tempFile.writeAsBytes(imageBytes);

//     // Set the _image variable to the temporary file
//     _image = tempFile;
//   } catch (e) {
//     print('Error decoding base64 image: $e');
//     _image = null;
//   }
// }geodesy: ^0.5.0

//   Future<void> decodeBase64Image(String base64Image) async {
//     File? _image;
//   try {

//     // Decode the base64-encoded string to bytes
//     List<int> imageBytes = base64Decode(base64Image);

//     // Create a temporary file and write the bytes to it
//     final tempDir = await getTemporaryDirectory();
//     final tempFile = File('${tempDir.path}/temp_image.jpg');
//     await tempFile.writeAsBytes(imageBytes);

//     // Set the _image variable to the temporary file
//     _image = tempFile;
//   } catch (e) {
//     print('Error decoding base64 image: $e');
//     _image = null;
//   }
// }

  String userName = '';
  Future<void> getusername() async {
    try {
      final uri = Uri.parse("http://192.168.33.248:6174/get_username");
      Map<String, dynamic> request = {"phone": widget.phone};
      final response = await http.post(uri, body: json.encode(request));

      final username = await http.get(uri);
      print(username.body);
      setState(() {
        userName = username.body;
      });
    } catch (e) {
      print(e);
    }
  }

  Timer? _timer;
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 25), (timer) {
      get_places();
    });
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    final geo.Geodesy geodesy = geo.Geodesy();
    final geo.Distance distance = geo.Distance();

    return distance(
      geo.LatLng(point1.latitude, point1.longitude),
      geo.LatLng(point2.latitude, point2.longitude),
    );
  }

  // Map<String, dynamic>? Places;
  Future<void> get_places() async {
    try {
      final Uint8List markerIcon =
          await getBytessFromAssets('assets/Marker.png', 100);
      final uri = Uri.parse("http://192.168.33.248:6174/get_places");

      final currplaces = await http.get(uri);

      // setState(() {
      //   Places = currplaces.bo;
      // });
      Map<String, dynamic> jsonData = json.decode(currplaces.body);
      // print(jsonData["contribution_of_food"][0]);

      jsonData["contribution_of_food"].forEach((item) {
        if (!_markers.any((marker) =>
            marker.position == LatLng(item["latitude"], item["longitude"]))) {
          Marker newMarker = Marker(
            markerId: MarkerId("marker_${_markers.length + 1}"),
            position: LatLng(item["latitude"], item["longitude"]),
            infoWindow: InfoWindow(
                title: "Food",
                snippet: '${item["endTime"]} ${item["endDate"]}'),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            onTap: () {
              double distance = calculateDistance(
                  LatLng(item["latitude"], item["longitude"]),
                  _currentLocation!);

              if (distance < 200) {
                // _showVerificationPopup();
                setState(() {
                  type = "Food";
                  description = item["description"];
                  image_to_show = item["image"];
                  verifypopup = true;
                  thumbs = item;

                  popup = false;
                });
              } else {
                setState(() {
                  popup = true;
                  verifypopup = false;
                  destination = LatLng(item["latitude"], item["longitude"]);
                  type = "Food";
                  distance_to_show = distance;
                  description = item["description"];
                  image_to_show = item["image"];
                });

                // _showMarkerPopup(LatLng(item["latitude"], item["longitude"]),
                //     "Food", item["description"]);
              }
            },
          );

          setState(() {
            _markers.add(newMarker);
          });
        }
      });
      jsonData["contribution_of_shelter"].forEach((item) {
        if (!_markers.any((marker) =>
            marker.position == LatLng(item["latitude"], item["longitude"]))) {
          Marker newMarker = Marker(
            markerId: MarkerId("marker_${_markers.length + 1}"),
            position: LatLng(item["latitude"], item["longitude"]),
            infoWindow: InfoWindow(
                title: "Shelter",
                snippet: '${item["endTime"]} ${item["endDate"]}'),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            onTap: () {
              double distance = calculateDistance(
                  LatLng(item["latitude"], item["longitude"]),
                  _currentLocation!);

              if (distance < 200) {
                // _showVerificationPopup();
                setState(() {
                  verifypopup = true;
                  popup = false;
                  thumbs = item;
                  type = "Shelter";
                  description = item["description"];
                  image_to_show = item["image"];
                });
              } else {
                setState(() {
                  popup = true;
                  verifypopup = false;
                  destination = LatLng(item["latitude"], item["longitude"]);
                  type = "Shelter";
                  distance_to_show = distance;
                  description = item["description"];
                  image_to_show = item["image"];
                });
                // _showMarkerPopup(LatLng(item["latitude"], item["longitude"]),
                //     "Shelter", item["description"]);
              }
            },
          );

          setState(() {
            _markers.add(newMarker);
          });
        }
      });
      jsonData["contribution_of_clothes"].forEach((item) {
        if (!_markers.any((marker) =>
            marker.position == LatLng(item["latitude"], item["longitude"]))) {
          Marker newMarker = Marker(
            markerId: MarkerId("marker_${_markers.length + 1}"),
            position: LatLng(item["latitude"], item["longitude"]),
            infoWindow: InfoWindow(
                title: "Clothes",
                snippet: '${item["endTime"]} ${item["endDate"]}'),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            onTap: () {
              double distance = calculateDistance(
                  LatLng(item["latitude"], item["longitude"]),
                  _currentLocation!);

              if (distance < 200) {
                // _showVerificationPopup();
                setState(() {
                  verifypopup = true;
                  popup = false;
                  thumbs = item;
                  type = "Clothes";
                  description = item["description"];
                  image_to_show = item["image"];
                });
              } else {
                setState(() {
                  popup = true;
                  verifypopup = false;
                  destination = LatLng(item["latitude"], item["longitude"]);
                  type = "Clothes";
                  distance_to_show = distance;
                  description = item["description"];
                  image_to_show = item["image"];
                });
                // _showMarkerPopup(LatLng(item["latitude"], item["longitude"]),
                //     "Clothes", item["description"]);
              }
            },
          );

          setState(() {
            _markers.add(newMarker);
          });
        }
      });
      jsonData["contribution_of_needy"].forEach((item) {
        if (!_markers.any((marker) =>
            marker.position == LatLng(item["latitude"], item["longitude"]))) {
          Marker newMarker = Marker(
            markerId: MarkerId("marker_${_markers.length + 1}"),
            position: LatLng(item["latitude"], item["longitude"]),
            infoWindow: InfoWindow(
                title: "Needy",
                snippet: '${item["endTime"]} ${item["endDate"]}'),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            // startTime: item["start_time"],
            //endTime: item["end_time"],

            onTap: () {
              double distance = calculateDistance(
                  LatLng(item["latitude"], item["longitude"]),
                  _currentLocation!);

              if (distance < 200) {
                // _showVerificationPopup();
                setState(() {
                  verifypopup = true;
                  popup = false;
                  thumbs = item;
                  type = "Needy";
                  description = item["description"];
                  image_to_show = item["image"];
                });
              } else {
                setState(() {
                  popup = true;
                  verifypopup = false;
                  destination = LatLng(item["latitude"], item["longitude"]);
                  type = "Needy";
                  distance_to_show = distance;
                  description = item["description"];
                  image_to_show = item["image"];
                });
                // _showMarkerPopup(LatLng(item["latitude"], item["longitude"]),
                //     "Needy", item["description"]);
              }
            },
          );

          setState(() {
            _markers.add(newMarker);
          });
        }
      });
      Set<Marker> to_remove = {};
      for (Marker marker in _markers) {
        String value = marker.infoWindow.snippet.toString();
        if (marker.infoWindow.title == "My Location") {
          continue;
        }
        if (isCurrentTimeGreaterThanMarkerTime(value)) {
          to_remove.add(marker);
          //setState(() {
          // _markers.remove(marker);
          // });
        }
      }

      for (Marker marker in to_remove) {
        setState(() {
          _markers.remove(marker);
        });
      }

      if (filter_flag == "all") {
        setState(() {
          _markers_to_display = _markers;
        });
      } else {
        setState(() {
          _markers_to_display = _markers
              .where((element) =>
                  element.infoWindow.title == filter_flag ||
                  element.infoWindow.title == "My Location")
              .toSet();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void StartListening() async {
    await _speech.listen(onResult: (result) {
      setState(() {
        _searchController.text = result.recognizedWords;
        Future.delayed(Duration(seconds: 1), () {
          _filterPlaces(_searchController.text);
        });
      });
    });
  }

  void StopListening() async {
    await _speech.stop();
    setState(() {});
  }

  void _filterPlaces(String query) {
    setState(() {
      _filteredPlaceList = _placeList
          .where((place) =>
              place['description'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<Position> getUserCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<LatLng>> getPolylinesPoints(
      LatLng origin, LatLng destination) async {
    PointLatLng Origin = PointLatLng(origin.latitude, origin.longitude);
    PointLatLng Destination =
        PointLatLng(destination.latitude, destination.longitude);
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyBIYLEFVCl9maBoD7lGZgAk5p4fYfejs-g", Origin, Destination);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  final Set<Marker> _markers = {};
  Set<Marker> _markers_to_display = {};
  String searchAddr = 'search';
  Future<Uint8List> getBytessFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _startTimer();
    if (userName == '') {
      getusername();
    }
    loadFunc();
    _searchController.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestions(_searchController.text);
  }

  void getSuggestions(String input) async {
    String kPLACES_API_KEY = "AIzaSyBIYLEFVCl9maBoD7lGZgAk5p4fYfejs-g";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      setState(() {
        _placeList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  void generatePolyLinesfromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId Id = PolylineId("poly");
    Polyline polygline = Polyline(
        polylineId: Id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 6);
    setState(() {
      polylines[Id] = polygline;
    });
  }

  LatLng destination = LatLng(37, 21);
  String type = 'Food';
  String description = 'Hi';
  double distance_to_show = 0;
  String? image_to_show;
  bool popup = false;
  bool verifypopup = false;

  Map<String, dynamic>? thumbs;

  Widget _showVerificationPop(String type, String description, String image) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 594.68,
            left: 30.11,
            child: Container(
              width: 331.66,
              height: 167.95, // Increased height to accommodate buttons
              padding: const EdgeInsets.all(21.89),
              decoration: ShapeDecoration(
                color: Color.fromARGB(131, 120, 108, 254),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.27),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 43.78,
                    offset: Offset(0, 5.47),
                    spreadRadius: 0,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 614,
            left: 121,
            child: Text(
              type,
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 19.70,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 0.07,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Positioned(
            left: 194,
            top: 603,
            child: Image.asset(
              'assets/verify_mark.png',
              width: 20,
              height: 20,
            ),
          ),

          //  Add Image Here
          Positioned(
            left: 50,
            top: 603,
            child: Container(
              width: 60, // Set the width
              height: 80, // Set the height
              child: Image.memory(base64Decode(image),
                  fit: BoxFit.cover), // Adjust fit as needed
            ),
          ),

          Positioned(
            right: 50,
            top: 603,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  verifypopup = false;
                });
              },
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(0xFF3D2EF5), // Change this to your desired color
                  BlendMode.modulate, // You can change blend mode as needed
                ),
                child: Image.asset(
                  'assets/close.png', // Replace with your image path
                  color: Colors.white,
                  width: 20, // Adjust width as needed
                  height: 20, // Adjust height as needed
                ),
              ),
            ),
          ),
          Positioned(
            left: 124.27,
            top: 637,
            child: SizedBox(
              width: 192.65,
              child: Container(
                child: Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Color.fromARGB(255, 31, 0, 0),
                    fontSize: 15.32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.0, // Adjust the line height
                    decoration: TextDecoration.none, // Remove underline
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 118,
            top: 703,
            child: Container(
              width: 152,
              height: 35,
              child: Stack(
                children: [
                  // Thumbs up button
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      icon: Icon(Icons.thumb_up),
                      color: Colors.green,
                      onPressed: () async {
                        setState(() {
                          verifypopup = false;
                        });

                        try {
                          final uri =
                              Uri.parse("http://192.168.33.248:6174/thumbs_up");

                          //print(request);
                          final response =
                              await http.post(uri, body: json.encode(thumbs));
                          // print(thumbs);

                          // setState(() {
                          //   print(response.body);
                          // });
                        } catch (e) {
                          print(e);
                        }

                        // Handle thumbs up button press
                      },
                    ),
                  ),
                  // Thumbs down button
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: Icon(Icons.thumb_down),
                      color: Colors.red,
                      onPressed: () async {
                        setState(() {
                          verifypopup = false;
                        });

                        try {
                          final uri = Uri.parse(
                              "http://192.168.33.248:6174/thumbs_down");

                          //print(request);
                          final response =
                              await http.post(uri, body: json.encode(thumbs));
                          // print(thumbs);r

                          // setState(() {
                          //   print(response.body);
                          // });
                        } catch (e) {
                          print(e);
                        }

                        // Handle thumbs down button press
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Position? _currentPosition;
  Widget _showMarkerPopup(LatLng Destination, String type, String description,
      String image, double distance) {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 584.68,
            left: 30.11,
            child: Container(
              width: 331.66,
              height: 177.95,
              padding: const EdgeInsets.all(21.89),
              decoration: ShapeDecoration(
                color: Color.fromARGB(123, 120, 108, 254),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.27),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 43.78,
                    offset: Offset(0, 5.47),
                    spreadRadius: 0,
                  )
                ],
              ), // Set background color with opacity
            ),
          ),
          Positioned(
              top: 604,
              left: 121,
              child: Text(
                type,
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 19.70,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 0.07,
                  decoration: TextDecoration.none, // Remove underline
                ),
              )),
          Positioned(
            left: 194,
            top: 593,
            child: Image.asset(
              'assets/verify_mark.png', // Replace with your image path
              width: 20, // Adjust width as needed
              height: 20, // Adjust height as needed
            ),
          ),

          //  Add Image Here

          Positioned(
            left: 50,
            top: 603,
            child: Container(
              width: 60, // Set the width
              height: 80, // Set the height
              child: Image.memory(base64Decode(image),
                  fit: BoxFit.cover), // Adjust fit as needed
            ),
          ),

          Positioned(
            right: 50,
            top: 593,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  popup = false;
                });
              },
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(0xFF3D2EF5), // Change this to your desired color
                  BlendMode.modulate, // You can change blend mode as needed
                ),
                child: Image.asset(
                  'assets/close.png', // Replace with your image path
                  color: Colors.white,
                  width: 20, // Adjust width as needed
                  height: 20, // Adjust height as needed
                ),
              ),
            ),
          ),
          Positioned(
            left: 124.27,
            top: 630,
            child: SizedBox(
              width: 192.65,
              child: Container(
                child: Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15.32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.0, // Adjust the line height
                    decoration: TextDecoration.none, // Remove underline
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 124.27,
            top: 650,
            child: SizedBox(
              width: 192.65,
              child: Container(
                child: Text(
                  '${distance/1000} Km away from you',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15.32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.0, // Adjust the line height
                    decoration: TextDecoration.none, // Remove underline
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              left: 38,
              top: 703,
              child: Container(
                width: 152,
                height: 35,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 152,
                        height: 35,
                        decoration: ShapeDecoration(
                          color: Color(0xFF3D2EF5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 23.05,
                      top: 7.25,
                      child: Text(
                        'Safe  route',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Cabin',
                          fontWeight: FontWeight.w500,
                          height: 0,
                          decoration: TextDecoration.none, // Remove underline
                        ),
                      ),
                    ),
                    Positioned(
                      left: 110,
                      top: 7.8,
                      child: GestureDetector(
                        onTap: () {
                          getPolylinesPoints(
                                  LatLng(_currentPosition!.latitude,
                                      _currentPosition!.longitude),
                                  Destination)
                              .then((value) =>
                                  {generatePolyLinesfromPoints(value)});
                          // Navigator.of(context).pop();
                          setState(() {
                            popup = false;
                          });
                        },
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Color.fromARGB(255, 255, 255,
                                255), // Change this to your desired color
                            BlendMode
                                .modulate, // You can change blend mode as needed
                          ),
                          child: Image.asset(
                            'assets/show_route.png', // Replace with your image path
                            color: Colors.white,
                            width: 20, // Adjust width as needed
                            height: 20, // Adjust height as needed
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  LatLng? _currentLocation;
  loadFunc() {
    getUserCurrentLocation().then((value) async {
      final Uint8List markerIcon =
          await getBytessFromAssets('assets/User.png', 250);
      _markers.add(Marker(
          markerId: MarkerId('-1'),
          position: LatLng(value.latitude, value.longitude),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: const InfoWindow(title: 'My Location')));

      _currentLocation = LatLng(value.latitude, value.longitude);
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 18,
      );
      get_places();
      _currentPosition = value;

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  void changeCameraPosition(double latitude, double longitude) async {
    if (_controller.isCompleted) {
      // print(latitude);
      // print(longitude);
      final GoogleMapController controller = await _controller.future;
      CameraPosition cameraPosition =
          CameraPosition(target: LatLng(latitude, longitude), zoom: 13);

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  double responsiveWidth(double input) {
    return input * MediaQuery.of(context).size.width / 410;
  }

  double responsiveHeight(double input) {
    return input * MediaQuery.of(context).size.height / 899;
  }

  Future<String> _translateText(String text, {String toLanguage = 'en'}) async {
    Translation translation = await translator.translate(text, to: toLanguage);
    return translation.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 410,
        height: 899,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3F6F5105),
              blurRadius: 131.35,
              offset: Offset(-10.95, 10.95),
              spreadRadius: 0,
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              child: Container(
                // Set the width and height to match the Google Map container
                width: 367, // Adjust these values if needed
                height: 722, // Adjust these values if needed
                margin: EdgeInsets.only(top: 145.0, right: 20.0),
                padding: EdgeInsets.only(left: 23.0, bottom: 70.0),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.27),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26.27),
                  child: Container(
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(17.423321, 78.543633),
                        zoom: 18,
                      ),
                      markers: _markers_to_display,
                      polylines: Set<Polyline>.of(polylines.values),
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) {
                          _controller.complete(controller);

                          setState(() {
                            markers[MarkerId("marker_1")] = Marker(
                              markerId: MarkerId("marker_1"),
                              position: LatLng(17.385044, 78.486671),
                              infoWindow: InfoWindow(
                                title: "Marker Title",
                                snippet: "Marker Snippet",
                              ),
                              icon: BitmapDescriptor.defaultMarker,
                            );
                          });
                        }
                      },
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 39,
              left: 23,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                child: Container(
                  width: 332,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFAFAFA),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Color.fromARGB(255, 199, 199, 255),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.search, color: Color(0xFFA6A6A6)),
                      ),
                      Text(
                        searchAddr,
                        style: TextStyle(
                          color: Color(0xFFA6A6A6),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.56,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 359,
              top: 48,
              child: GestureDetector(
                onTap: () {
                  // Handle the click event here
                  if (!_speechEnabled) {
                    initSpeech();
                  }
                  StartListening();
                  _isSearching = true;
                },
                child: Container(
                  width: 24,
                  height: 24,
                  child: Stack(
                    children: [
                      Container(
                        width: 24, // Adjust the width to increase the size
                        height: 24, // Adjust the height to increase the size
                        child: Image.asset(
                          'assets/sound_max_fill.png', // Replace with the actual path or asset name
                          fit: BoxFit
                              .cover, // You can adjust the fit property as needed
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                left: 22,
                top: 85,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      filter_flag = 'all';
                    });
                    setState(() {
                      _markers_to_display = _markers;
                    });
                  },
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                              width: 31,
                              height: 31,
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    color: filter_flag == 'all'
                                        ? Color(0xFF3D2EF5)
                                        : Color(0xFF646464),
                                  ),
                                ),
                              ),
                              child: filter_flag == 'all'
                                  ? Image.asset('assets/all.png')
                                  : Image.asset('assets/all.png')),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                left: 38,
                top: 127,
                child: FutureBuilder<String>(
                  future: _translateText('All', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: filter_flag == 'all'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: filter_flag == 'all'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),
            Positioned(
                left: 73,
                top: 85,
                child: IconButton(
                  onPressed: () {},
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 31,
                            height: 31,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(
                                side: BorderSide(
                                    width: 1, color: Color(0xFF646464)),
                              ),
                            ),
                            child: Image.asset(
                                'assets/weather.png'), // Replace with the actual path or asset name
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
              left: 77,
              top: 127,
              child: FutureBuilder<String>(
                  future:
                      _translateText('Disaster', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: Color(0xFFA6A6A6),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: Color(0xFFA6A6A6),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ),

            Positioned(
                left: 126,
                top: 85,
                child: IconButton(
                  onPressed: () {},
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 31,
                            height: 31,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(
                                side: BorderSide(
                                    width: 1, color: Color(0xFF646464)),
                              ),
                            ),
                            child: Image.asset(
                                'assets/animal.png'), // Replace with the actual path or asset name
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            Positioned(
                left: 132,
                top: 127,
                child: FutureBuilder<String>(
                  future: _translateText('Animal', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: Color(0xFFA6A6A6),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: Color(0xFFA6A6A6),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),

            Positioned(
                left: 176,
                top: 85,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      filter_flag = 'Food';
                    });
                    setState(() {
                      _markers_to_display = _markers
                          .where((element) =>
                              element.infoWindow.title == filter_flag ||
                              element.infoWindow.title == "My Location")
                          .toSet();
                    });
                  },
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                              width: 31,
                              height: 31,
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: filter_flag == 'Food'
                                        ? Color(0xFF3D2EF5)
                                        : Color(0xFF646464),
                                  ),
                                ),
                              ),
                              child: filter_flag == 'Food'
                                  ? Image.asset('assets/food.png')
                                  : Image.asset(
                                      'assets/images/Group 48095600.png')), // Replace with the actual path or asset name
                        ),
                      ],
                    ),
                  ),
                )),

            Positioned(
                left: 186,
                top: 127,
                child: FutureBuilder<String>(
                  future: _translateText('Food', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: filter_flag == 'Food'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: filter_flag == 'Food'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),

            Positioned(
                left: 226,
                top: 85,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      filter_flag = 'Clothes';
                    });
                    setState(() {
                      _markers_to_display = _markers
                          .where((element) =>
                              element.infoWindow.title == filter_flag ||
                              element.infoWindow.title == "My Location")
                          .toSet();
                    });
                  },
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                              width: 31,
                              height: 31,
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: filter_flag == 'Clothes'
                                        ? Color(0xFF3D2EF5)
                                        : Color(0xFF646464),
                                  ),
                                ),
                              ),
                              child: filter_flag == 'Clothes'
                                  ? Image.asset('assets/images/clothes.png')
                                  : Image.asset('assets/animal.png')),
                        ),
                      ],
                    ),
                  ),
                )),

            Positioned(
                left: 231,
                top: 127,
                child: FutureBuilder<String>(
                  future:
                      _translateText('Clothes', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: filter_flag == 'Clothes'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: filter_flag == 'Clothes'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),

            Positioned(
                left: 277,
                top: 85,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      filter_flag = 'Shelter';
                    });
                    setState(() {
                      _markers_to_display = _markers
                          .where((element) =>
                              element.infoWindow.title == filter_flag ||
                              element.infoWindow.title == "My Location")
                          .toSet();
                    });
                  },
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 31,
                            height: 31,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: filter_flag == 'Shelter'
                                      ? Color(0xFF3D2EF5)
                                      : Color(0xFF646464),
                                ),
                              ),
                            ),
                            child: filter_flag == 'Shelter'
                                ? Image.asset('assets/images/shelter.png')
                                : Image.asset('assets/weather.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            Positioned(
                left: 285,
                top: 127,
                child: FutureBuilder<String>(
                  future:
                      _translateText('Shelter', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: filter_flag == 'Shelter'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: filter_flag == 'Shelter'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),

            Positioned(
                left: 328,
                top: 85,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      filter_flag = 'Needy';
                    });
                    setState(() {
                      _markers_to_display = _markers
                          .where((element) =>
                              element.infoWindow.title == filter_flag ||
                              element.infoWindow.title == "My Location")
                          .toSet();
                    });
                  },
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 31,
                            height: 31,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: filter_flag == 'Needy'
                                      ? Color(0xFF3D2EF5)
                                      : Color(0xFF646464),
                                ),
                              ),
                            ),
                            child: filter_flag == 'Needy'
                                ? Image.asset('assets/images/shelter.png')
                                : Image.asset('assets/weather.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            Positioned(
                left: 336,
                top: 127,
                child: FutureBuilder<String>(
                  future: _translateText('Needy', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: filter_flag == 'Needy'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: filter_flag == 'Needy'
                              ? Color(0xFF3D2EF5)
                              : Color(0xFF646464),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: -0.40,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),

            Positioned(
                left: 366,
                top: 88,
                child: IconButton(
                  onPressed: () {},
                  icon: Container(
                    width: 31,
                    height: 31,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 31,
                            height: 31,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(
                                side: BorderSide(
                                    width: 1, color: Color(0xFF646464)),
                              ),
                            ),
                            child: Image.asset(
                                'assets/images/arrow-left.png'), // Replace with the actual path or asset name
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            // Bottom:

            Positioned(
              bottom: 43,
              left: 89,
              child: GestureDetector(
                onTap: () {
                  // Handle the click event here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyFood(
                              phone: widget.phone,
                              UserName: userName,
                              language: widget.language,
                              currentLocation: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude),
                            )),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: ShapeDecoration(
                            shape: CircleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Color(0xFF646464),
                              ),
                            ),
                          ),
                          child: Image.asset(
                            'assets/contribute.png', // Replace with the actual path or asset name
                            width:
                                60, // Adjust the width of the image as needed
                            height:
                                60, // Adjust the height of the image as needed
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
                left: 91,
                bottom: 30,
                child: FutureBuilder<String>(
                  future:
                      _translateText('Contribute', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.17,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.17,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),

            Positioned(
              bottom: 43,
              left: 245,
              child: Container(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/border.png', // Replace with the actual path or asset name for the outer image
                      width: 60,
                      height: 60,
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          'assets/angel.png', // Replace with the actual path or asset name for the inner image
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
                left: 260,
                bottom: 30,
                child: FutureBuilder<String>(
                  future: _translateText('Angel', toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.17,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 0.17,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),
            if (_isSearching)
              Positioned.fill(
                top: 39,
                left: 0,
                child: Container(
                  width: 332,
                  height: 300, // Adjust height according to your requirement
                  decoration: ShapeDecoration(
                    color: Color(0xFFFAFAFA),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Color.fromARGB(255, 199, 199, 255),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 23),
                                border: InputBorder.none,
                                hintText: 'Search',
                              ),
                              onChanged: (value) {
                                _filterPlaces(value);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearching = false;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredPlaceList.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<String>(
                              future: _translateText(
                                  _filteredPlaceList[index]['description'],
                                  toLanguage: widget.language),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListTile(
                                    title: Text(snapshot.data!),
                                    onTap: () async {
                                      List<Location> locations =
                                          await locationFromAddress(
                                              _filteredPlaceList[index]
                                                  ['description']);

                                      setState(() {
                                        _isSearching = false;
                                        _placeList = [];
                                        _searchController.clear();
                                        searchAddr = _filteredPlaceList[index]
                                            ['description'];
                                        if (searchAddr.length < 42) {
                                          searchAddr = searchAddr.substring(
                                              0, searchAddr.length);
                                        } else {
                                          searchAddr =
                                              searchAddr.substring(0, 42);
                                        }
                                        searchAddr = searchAddr + '...';
                                      });

                                      changeCameraPosition(
                                          locations.last.latitude,
                                          locations.last.longitude);
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return ListTile(
                                    title: Text('Error: ${snapshot.error}'),
                                    onTap: () async {
                                      List<Location> locations =
                                          await locationFromAddress(
                                              _filteredPlaceList[index]
                                                  ['description']);

                                      setState(() {
                                        _isSearching = false;
                                        _placeList = [];
                                        _searchController.clear();
                                        searchAddr = _filteredPlaceList[index]
                                            ['description'];
                                        if (searchAddr.length < 42) {
                                          searchAddr = searchAddr.substring(
                                              0, searchAddr.length);
                                        } else {
                                          searchAddr =
                                              searchAddr.substring(0, 42);
                                        }
                                        searchAddr = searchAddr + '...';
                                      });

                                      changeCameraPosition(
                                          locations.last.latitude,
                                          locations.last.longitude);
                                    },
                                  );
                                } else {
                                  return ListTile(
                                    title: CircularProgressIndicator(),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
                child: popup
                    ? _showMarkerPopup(destination, type, description,
                        image_to_show!, distance_to_show)
                    : Container(
                        width: 0.0,
                        height: 0.0,
                        color: Colors
                            .transparent, // Optionally, set a transparent color
                      )),
            Positioned(
                child: verifypopup
                    ? _showVerificationPop(type, description, image_to_show!)
                    : Container(
                        width: 0.0,
                        height: 0.0,
                        color: Colors.transparent,
                      )),
          ],
        ),
      ),
      floatingActionButton: _isSearching
          ? null
          : Padding(
              padding: EdgeInsets.only(bottom: 275.0, right: 14.0),
              child: FloatingActionButton(
                onPressed: () {
                  loadFunc();
                },
                child: Icon(Icons.my_location),
              ),
            ),
    );
  }
}
