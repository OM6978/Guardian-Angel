import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:roti_kapda_makan/Views/location.dart';
import 'package:roti_kapda_makan/Views/user_details.dart';
import 'package:translator/translator.dart';
import 'package:roti_kapda_makan/Views/validation.dart';

String languageCode = 'en';

class SelectLanguage extends StatefulWidget {
  String phone;
  String language = 'en';
  bool check;

  SelectLanguage(
      {Key? key,
      required this.phone,
      required this.language,
      required this.check})
      : super(key: key);

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  final translator = GoogleTranslator();

  List<bool> boolList = List.generate(12, (index) => false);

  Future<String> _translateText(String text, {String toLanguage = 'en'}) async {
    Translation translation = await translator.translate(text, to: toLanguage);
    return translation.text;
  }

  Widget translate(String text, TextStyle txtstyle, String code) {
    return FutureBuilder<String>(
      future: _translateText(text, toLanguage: code),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: txtstyle,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: txtstyle);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Color initbackgroundColor = Colors.transparent; // Default background color
  Color inittextColor = Color(0xFF3D2EF5); // Default text color

  Color textColor = Colors.white;
  Color backgroundColor = Color(0xFF3D2EF5);

  @override
  void initState() {
    super.initState();
    boolList[2] = true;
    widget.language = 'en';
  }

  Widget createLanguageContainer(String text, String code, int num) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.language = code;
          boolList = List.generate(12, (index) => false);
          boolList[num] = true;
        });
      },
      child: Container(
        width: 81,
        height: 39,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0xFF3D2EF5)),
            borderRadius: BorderRadius.circular(8),
          ),
          color: boolList[num]
              ? backgroundColor
              : initbackgroundColor, // Use this color variable
        ),
        child: Center(
            child: translate(
                text,
                TextStyle(
                  color: boolList[num] ? textColor : inittextColor,
                  fontSize: 16,
                  fontFamily: 'Cabin',
                  fontWeight: FontWeight.w500,
                  height: 0,
                ),
                code)),
      ),
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
            ),
            child: Stack(
              children: [
                Positioned(
                    top: 114,
                    left: 32,
                    child: Text(
                      'Select Language',
                      style: TextStyle(
                        color: Color(0xFF5E5E62),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 0.07,
                      ),
                    )),
                Positioned(
                    top: 169,
                    left: 27,
                    child: createLanguageContainer("Hindi Language", 'hi', 0)),
                Positioned(
                    top: 169,
                    left: 119,
                    child: createLanguageContainer("Marathi", 'mr', 1)),
                Positioned(
                    top: 169,
                    left: 211,
                    child: createLanguageContainer("English", 'en', 2)),
                Positioned(
                    top: 169,
                    left: 303,
                    child: createLanguageContainer("Telugu", 'te', 3)),
                Positioned(
                    top: 219,
                    left: 27,
                    child: createLanguageContainer("Marwari", 'hi', 4)),
                Positioned(
                    top: 219,
                    left: 119,
                    child: createLanguageContainer("Bengali", 'bn', 5)),
                Positioned(
                    top: 219,
                    left: 211,
                    child: createLanguageContainer("Tamil", 'ta', 6)),
                Positioned(
                    top: 219,
                    left: 303,
                    child: createLanguageContainer("Gujrati", 'gu', 7)),
                Positioned(
                    top: 269,
                    left: 27,
                    child: createLanguageContainer("Assamese", 'as', 8)),
                Positioned(
                    top: 269,
                    left: 119,
                    child: createLanguageContainer("Pahari", 'en', 9)),
                Positioned(
                    top: 269,
                    left: 211,
                    child: createLanguageContainer("Kannada", 'kn', 10)),
                Positioned(
                    top: 269,
                    left: 303,
                    child: createLanguageContainer("Oriya", 'or', 11)),
                Positioned(
                    left: 120,
                    bottom: 66,
                    child: Container(
                      width: 160,
                      height: 56,
                      child: GestureDetector(
                        onTap: () {
                          // Add your onTap functionality here

                          if (widget.check) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Validation(
                                    phone: widget.phone,
                                    language: widget.language),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyLocation(
                                    phone: widget.phone,
                                    language: widget.language),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 160,
                                height: 56,
                                decoration: ShapeDecoration(
                                  color: Color(0xFF3D2EF5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            )));
  }
}
