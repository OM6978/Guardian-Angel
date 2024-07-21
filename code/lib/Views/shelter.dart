import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roti_kapda_makan/Views/edit_location.dart';
import 'package:roti_kapda_makan/Views/food.dart';
import 'package:roti_kapda_makan/Views/clothes.dart';
import 'package:roti_kapda_makan/Views/home.dart';
import 'package:roti_kapda_makan/Views/needy.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class MyShelter extends StatefulWidget {
  final String phone;
  final String UserName;
  final String language;
  LatLng? currentLocation;
  MyShelter(
      {super.key,
      required this.phone,
      required this.UserName,
      this.currentLocation,
      required this.language});

  @override
  State<MyShelter> createState() => _MyShelterState();
}

class _MyShelterState extends State<MyShelter> {
  bool speechEnabled = false;

  final SpeechToText _speech = SpeechToText();
  TextEditingController description_controller = TextEditingController();

  File? _image;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
        endDate = picked.add(Duration(days: 1));
      });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
      });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime)
      setState(() {
        startTime = picked;
        endTime = TimeOfDay(hour: picked.hour + 1, minute: picked.minute);
      });
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime)
      setState(() {
        endTime = picked;
      });
  }

  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print("NO Image Selected");
      }
    });
  }

  final translator = GoogleTranslator();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchAddress();
  }

  void initSpeech() async {
    speechEnabled = await _speech.initialize();
    setState(() {});
  }

  void StartListening() async {
    await _speech.listen(onResult: (result) {
      String temp = result.recognizedWords;
      setState(() {
        description_controller.text = temp;
      });
    });
  }

  void StopListening() async {
    await _speech.stop();
    setState(() {});
  }

  List<Placemark>? placemarks;
  Future<void> _fetchAddress() async {
    // print(widget.currentLocation.latitude);
    placemarks = await placemarkFromCoordinates(
        widget.currentLocation!.latitude, widget.currentLocation!.longitude);
    setState(() {});
  }

  Future<String> _translateText(String text, {String toLanguage = 'en'}) async {
    Translation translation = await translator.translate(text, to: toLanguage);
    return translation.text;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 410,
        height: 899,
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Color(0xCCE8E6FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.27),
              topRight: Radius.circular(26.27),
            ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 415,
              height: 71,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 415,
                      height: 71,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFD6D2FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(26.27),
                            topRight: Radius.circular(26.27),
                          ),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3FD4D4D4),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),

                  // Close button

                  Positioned(
                    left: 356,
                    top: 29,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Stack(
                        children: [
                          Positioned(
                              // left: 0,
                              // top: 36,
                              child: FutureBuilder<String>(
                            future: _translateText('Close',
                                toLanguage: widget.language),
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
                            // left: 3,
                            // top: 9,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(
                                              phone: widget.phone,
                                              language: widget.language,
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/Close_round_fill.png',
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 25,
                    top: 17,
                    child: SizedBox(
                      width: 372,
                      height: 37,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 37,
                              height: 37,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.5),
                                  side: const BorderSide(
                                      width: 4, color: Color(0xFF3D2EF5)),
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/Vector.png',
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              left: 136,
                              top: 11,
                              child: FutureBuilder<String>(
                                future: _translateText('Contribute',
                                    toLanguage: widget.language),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                        color: Color(0xFF4C4C4C),
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                        letterSpacing: -0.80,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(
                                      'Error: ${snapshot.error}',
                                      style: TextStyle(
                                        color: Color(0xFF4C4C4C),
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                        letterSpacing: -0.80,
                                      ),
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              )),
                          Positioned(
                            left: 356,
                            top: 9,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 2,
                                    top: 2,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              "https://via.placeholder.com/12x12"),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 372,
              height: 180,
              child: Stack(
                children: [
                  Positioned(
                    left: 25,
                    top: 18,
                    child: Text(
                      widget.UserName,
                      style: TextStyle(
                        color: Color(0xFF4C4C4C),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 0,
                        letterSpacing: -0.64,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 250,
                    top: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Image.asset(
                            'assets/images/mdi_location.png',
                          ),
                        ),
                        Text(
                          placemarks == null
                              ? "Loading..."
                              : placemarks!.reversed.last.name
                                      .toString()
                                      .substring(
                                          0,
                                          min(
                                              10,
                                              placemarks!.reversed.last.name
                                                  .toString()
                                                  .length)) +
                                  '...',
                          style: TextStyle(
                            color: Color(0xFF3D2EF5),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.48,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                          currentLocation:
                                              widget.currentLocation,
                                        )),
                              ).then((returnValue) {
                                // Handle the return value here
                                // if (returnValue != null) {
                                // print(
                                //     'Returned value from MapScreen: $returnValue');
                                print(returnValue);
                                setState(() {
                                  widget.currentLocation = returnValue;
                                  _fetchAddress();
                                });
                                // Do whatever you need with the returned value
                                // }
                              });
                              // Add your onTap functionality here
                              // You can navigate to another screen, show a dialog, or perform any action you desire.
                            },
                            child: Image.asset(
                              'assets/images/edit.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      left: 25,
                      top: 60,
                      child: FutureBuilder<String>(
                        future: _translateText('Choose Domain to contribute',
                            toLanguage: widget.language),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              style: TextStyle(
                                color: Color(0xFF646464),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: -0.56,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: Color(0xFF646464),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: -0.56,
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )),
                  Positioned(
                    left: 28,
                    top: 100,
                    child: SizedBox(
                      width: 36,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 10,
                              top: 36,
                              child: FutureBuilder<String>(
                                future: _translateText('All',
                                    toLanguage: widget.language),
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
                            left: 0,
                            top: 0,
                            child: SizedBox(
                              width: 31,
                              height: 31,
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 1,
                                        color: const Color(
                                            0xFF646464), // Adjust the color of the border as needed
                                      ),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/all.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 88,
                    top: 100,
                    child: SizedBox(
                      width: 38,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              top: 36,
                              child: FutureBuilder<String>(
                                future: _translateText('Animal',
                                    toLanguage: widget.language),
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
                            left: 3,
                            top: 0,
                            child: SizedBox(
                              width: 31,
                              height: 31,
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/Group 48095557.png',
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 210,
                    top: 100,
                    child: SizedBox(
                      width: 36,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 2,
                              top: 36,
                              child: FutureBuilder<String>(
                                future: _translateText('Food',
                                    toLanguage: widget.language),
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
                            left: 0,
                            top: 0,
                            child: SizedBox(
                              width: 31,
                              height: 31,
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyFood(
                                              phone: widget.phone,
                                              UserName: widget.UserName,
                                              language: widget.language,
                                              currentLocation:
                                                  widget.currentLocation,
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/Group 48095600.png', // Replace with the path to your PNG file
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 268,
                    top: 100,
                    child: SizedBox(
                      width: 36,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              top: 36,
                              child: FutureBuilder<String>(
                                future: _translateText('Clothes',
                                    toLanguage: widget.language),
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
                            left: 2,
                            top: 0,
                            child: SizedBox(
                              width: 31,
                              height: 31,
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyClothes(
                                              phone: widget.phone,
                                              UserName: widget.UserName,
                                              language: widget.language,
                                              currentLocation:
                                                  widget.currentLocation,
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/Group 48095557.png', // Replace with the path to your PNG file
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 329,
                    top: 100,
                    child: SizedBox(
                      width: 36,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              top: 36,
                              child: FutureBuilder<String>(
                                future: _translateText('Shelter',
                                    toLanguage: widget.language),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                        color: Color(0xFF3D2EF5),
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
                                        color: Color(0xFF3D2EF5),
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
                            left: 2,
                            top: 0,
                            child: SizedBox(
                              width: 31,
                              height: 31,
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyShelter(
                                              phone: widget.phone,
                                              UserName: widget.UserName,
                                              currentLocation:
                                                  widget.currentLocation,
                                              language: widget.language,
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/shelter.png', // Replace with the path to your PNG file
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 150,
                    top: 100,
                    child: SizedBox(
                      width: 34,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 31,
                              height: 31,
                              decoration: const ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(
                                      width: 1, color: Color(0xFF646464)),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  // Add your button onPressed logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Needy(
                                              phone: widget.phone,
                                              UserName: widget.UserName,
                                              language: widget.language,
                                              currentLocation:
                                                  widget.currentLocation,
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/Group 48095580.png', // Replace with the path to your PNG file
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              left: 0,
                              top: 35,
                              child: FutureBuilder<String>(
                                future: _translateText('Needy',
                                    toLanguage: widget.language),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 161.0, top: 8.0),
                child: FutureBuilder<String>(
                  future: _translateText('Description',
                      toLanguage: widget.language),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: Color(0xFF4C4C4C),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          color: Color(0xFF4C4C4C),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )),
            SizedBox(
              height: 71,
              child: Stack(
                children: [
                  Positioned(
                    left: 45,
                    top: 0,
                    child: Container(
                      width: 320,
                      height: 47,
                      padding: const EdgeInsets.only(
                        top: 0,
                        left: 16,
                        right: 28,
                        bottom: 0,
                      ),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFFACA5FF)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: FutureBuilder<String>(
                          future: _translateText('Speak or Type',
                              toLanguage: widget.language),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return TextField(
                                controller: description_controller,
                                onChanged: (value) {
                                  description_controller.text = value;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: snapshot.data!,
                                  hintStyle: TextStyle(
                                    color: Color(0xFF4C4C4C),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                  border: InputBorder.none,
                                ),
                                focusNode: FocusNode(),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return TextField(
                                controller: description_controller,
                                onChanged: (value) {
                                  description_controller.text = value;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: '...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF4C4C4C),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                  border: InputBorder.none,
                                ),
                                focusNode: FocusNode(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 335, // Adjust the left position as needed
                    top: 11, // Adjust the top position as needed
                    child: GestureDetector(
                      onTap: () {
                        initSpeech();
                        StartListening();
                      },
                      child: Container(
                        child: Image.asset(
                          'assets/images/Mic_fill.png', // Replace with your image asset path
                          width: 24, // Adjust the width as needed
                          height: 24, // Adjust the height as needed
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (_image == null)
                  Padding(
                      padding: EdgeInsets.only(left: 11.0, top: 8.0),
                      child: FutureBuilder<String>(
                        future: _translateText('Upload Picture',
                            toLanguage: widget.language),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              style: TextStyle(
                                color: Color(0xFF4C4C4C),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: Color(0xFF4C4C4C),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )),
                SizedBox(
                  height: 71,
                  child: Stack(
                    children: [
                      _image == null
                          ? Positioned(
                              // When the image is not uploaded
                              left: 45,
                              top: 0,
                              child: Container(
                                width: 320,
                                height: 47,
                                padding: const EdgeInsets.only(
                                  top: 11,
                                  left: 16,
                                  right: 16,
                                  bottom: 12,
                                ),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFACA5FF),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // Add your onTap function here
                                    // For example, you can show a dialog or navigate to another screen
                                    getImage();
                                  },
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Positioned(
                                          left: 25,
                                          child: FutureBuilder<String>(
                                            future: _translateText('Photo',
                                                toLanguage: widget.language),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data!,
                                                  style: TextStyle(
                                                    color: Color(0xFFCACACA),
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.09,
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                  'Error: ${snapshot.error}',
                                                  style: TextStyle(
                                                    color: Color(0xFFCACACA),
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.09,
                                                  ),
                                                );
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            },
                                          )),
                                      Image.asset(
                                        'assets/images/mdi_camera.png',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Stack(
                              // After the image is uploaded
                              children: [
                                // Position the uploaded image at the top left corner with some padding
                                Positioned(
                                  top: 5,
                                  left: 170,
                                  child: Container(
                                    width: 80, // Adjust width as needed
                                    height: 80, // Adjust height as needed
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit
                                          .contain, // Maintain aspect ratio
                                    ),
                                  ),
                                ),

                                // Position the IconButton at the bottom right corner with some padding
                                Positioned(
                                  bottom: 16,
                                  right: 20.0,
                                  child: IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: getImage,
                                    color: Color.fromARGB(148, 123, 114, 114),
                                    iconSize: 30.0,
                                    padding: EdgeInsets.all(8.0),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text('Start Date'),
            ElevatedButton(
              onPressed: () => _selectStartDate(context),
              child: Text(
                '${startDate?.toLocal().toString().split(' ')[0].split('-').reversed.join('/') ?? 'Choose date'}',
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Text('End Date'),
            ElevatedButton(
              onPressed: () => _selectEndDate(context),
              child: Text(
                '${endDate?.toLocal().toString().split(' ')[0].split('-').reversed.join('/') ?? 'Choose date'}',
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    ),
    SizedBox(height: 20),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text('Start Time'),
            ElevatedButton(
              onPressed: () => _selectStartTime(context),
              child: Text(
                '${startTime?.format(context) ?? 'Choose time'}',
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Text('End Time'),
            ElevatedButton(
              onPressed: () => _selectEndTime(context),
              child: Text(
                '${endTime?.format(context) ?? 'Choose time'}',
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
),
            const SizedBox(width: 320, height: 15),
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Padding(
                padding: const EdgeInsets.only(left: 125.0),
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final uri = Uri.parse(
                            "http://192.168.33.248:6174/contribute_shelter");
                        print("OK");
                        String base64Image =
                            base64Encode(_image!.readAsBytesSync());
                        Map<String, dynamic> request = {
                          "description": description_controller.text.toString(),
                          "image": base64Image,
                          "phone": widget.phone,
                          "latitude": widget.currentLocation!.latitude,
                          "longitude": widget.currentLocation!.longitude,
                          "startDate": startDate
                              .toString()
                              .split(' ')[0]
                              .split('-')
                              .reversed
                              .join('/'),
                          "endDate": endDate
                              .toString()
                              .split(' ')[0]
                              .split('-')
                              .reversed
                              .join('/'),
                          "startTime":
                              '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                          "endTime":
                              '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                          "thumbsUp": 0,
                          "thumbsDown": 0,
                        };
                        print(request);
                        final response =
                            await http.post(uri, body: json.encode(request));
                        print(request);
                        // setState(() {
                        //   print(response.body);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(
                                    phone: widget.phone,
                                    language: widget.language,
                                  )),
                        );
                        // });
                      } catch (e) {
                        print(e);
                      }

                      // Add your submit logic here
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 56),
                      backgroundColor: const Color(0xFF3D2EF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: FutureBuilder<String>(
                      future:
                          _translateText('SUBMIT', toLanguage: widget.language),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Cabin',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Cabin',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
