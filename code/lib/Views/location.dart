import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roti_kapda_makan/Views/home.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class MyLocation extends StatefulWidget {
  final String phone;
  final String language;
  const MyLocation({Key? key, required this.phone,required this.language}) : super(key: key);

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  String userName = "";
  late Map<String, Future<String>> _translations;

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _translations = {
      'location': _translateText("Location is key!", toLanguage: widget.language),
      'next': _translateText('Next', toLanguage: widget.language)
      // Add more text fields here as needed
    };
    _getUsername();
  }

  Future<void> _getUsername() async {
    try {
      final uri = Uri.parse("http://192.168.84.248:6174/get_username");
      Map<String, dynamic> request = {"phone": widget.phone};
      final response = await http.post(uri, body: json.encode(request));

      final username = await http.get(uri);
      setState(() {
        userName = username.body;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _translateText(String text, {String toLanguage = 'en'}) async {
    Translation translation = await translator.translate(text, to: toLanguage);
    return translation.text;
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          shadows: const [
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
              top: 111,
              left: 172,
              child: SizedBox(
                width: 66,
                height: 14,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 26,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 52,
                      top: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const ShapeDecoration(
                          color: Color(0xFF3D2EF5),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 113,
              top: 160,
              child: SizedBox(
                width: 182,
                height: 89,
                child: Stack(
                  children: [
                    Positioned(
                      left: 63,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/logo.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 70,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'G',
                              style: TextStyle(
                                color: Color(0xFF3D2EF5),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 0.05,
                              ),
                            ),
                            TextSpan(
                              text: 'uardian Angel',
                              style: TextStyle(
                                color: Color(0xFF737373),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 0.05,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 314,
              left: 109,
              child: FutureBuilder<String>(
                future: _translations['location'],
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 0.05,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Color(0xFF909090),
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 0.05,
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            Positioned(
              width: 160,
              height: 56,
              top: 654,
              left: 125,
              child: ElevatedButton(
                onPressed: () async {
                  Position? userLocation = await _getUserCurrentLocation();
                  if (userLocation != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          phone: widget.phone,
                          language: widget.language
                        ),
                      ),
                    );
                  } else {
                    _showAlertDialog(
                      context,
                      'Alert',
                      'Kindly Allow the "Location Permission" To Continue.',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: SizedBox(
                  width: 160,
                  height: 56,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 160,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF3D2EF5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        top: 16,
                        left: 50,
                        child: FutureBuilder<String>(
                          future: _translations['next'],
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Position?> _getUserCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }
}
