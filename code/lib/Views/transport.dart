import 'dart:convert';

import 'package:roti_kapda_makan/Views/location.dart';
import 'package:roti_kapda_makan/Views/user_details.dart';
import 'package:translator/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Transportation extends StatefulWidget {
  String phone;
  String language;
  bool Selected;

  Transportation({
    Key? key,
    required this.phone,
    required this.language,
    required this.Selected,
  }) : super(key: key);

  @override
  State<Transportation> createState() => _TransportationState();
}

class _TransportationState extends State<Transportation> {
  bool isSelected = false;
  final translator = GoogleTranslator();

  Future<String> _translateText(String text, {String toLanguage = 'en'}) async {
    Translation translation = await translator.translate(text, to: toLanguage);
    return translation.text;
  }

  Widget translate(String text, TextStyle txtstyle) {
    return FutureBuilder<String>(
      future: _translateText(text, toLanguage: widget.language),
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

  List<bool> boolList = List.generate(4, (index) => false);

  Widget buildContainer(String img, String text, int num) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (boolList[num]) {
            boolList[num] = false;
          } else {
            boolList[num] = true;
            isSelected = true;
          }

          bool flag = false;

          for (int i = 0; i < boolList.length; i++) {
            if (boolList[i] == true) {
              flag = true;
              break;
            }
          }
          isSelected = flag;
        });
      },
      child: Container(
        width: 107,
        height: 39,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: ShapeDecoration(
                  color: boolList[num] ? Color(0xFF3D2EF5):Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFF3D2EF5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 7,
              child: Container(
                width: 22,
                height: 22,
                decoration: ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(
                      width: 1,
                      color: boolList[num] ?   Colors.white:Color(0xFF3D2EF5),
                    ),
                  ),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    boolList[num] ?   Colors.white:Color(0xFF3D2EF5),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    img,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 37,
              top: 10,
              child: translate(
                text,
                TextStyle(
                  color: boolList[num] ?   Colors.white:Color(0xFF3D2EF5),
                  fontSize: 16,
                  fontFamily: 'Cabin',
                  fontWeight: FontWeight.w500,
                  height: 0,
                ),
              ),
            ),
          ],
        ),
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
            child: Stack(children: [
              Positioned(
                  top: 137,
                  left: 32,
                  child: translate(
                      "What do you want to transport?",
                      TextStyle(
                        color: Color(0xFF5E5E62),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 0.07,
                      ))),
              Positioned(
                  left: 32,
                  top: 178,
                  child: buildContainer(
                      'assets/images/Group 48095600.png', 'Food', 0)),
              Positioned(
                  left: 159,
                  top: 178,
                  child: buildContainer('assets/shelter.png', 'Shelter', 1)),
              Positioned(
                  left: 283,
                  top: 178,
                  child: buildContainer('assets/cloth.png', 'Cloth', 2)),
              Positioned(
                  left: 32,
                  top: 234,
                  child: buildContainer('assets/animal.png', 'Animal', 3)),
              Positioned(
                  left: 120,
                  bottom: 66,
                  child: Container(
                      width: 160,
                      height: 56,
                      child: GestureDetector(
                          onTap: () async {
                            if (widget.Selected == true || isSelected == true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUp(
                                      phone: widget.phone,
                                      language: widget.language),
                                ),
                              );
                            } else {
                              try {
                                final uri = Uri.parse(
                                    "http://192.168.33.248:6174/upload_user_details");
                                Map<String, dynamic> request = {
                                  "firstName": "",
                                  "lastName": "",
                                  "dob": "",
                                  "gender": "",
                                  "phone": widget.phone
                                };
                                final response = await http.post(uri,
                                    body: json.encode(request));
                                print(response.body);
                              } catch (e) {
                                print(e);
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyLocation(
                                      phone: widget.phone,
                                      language: widget.language),
                                ),
                              );
                            }
                            // Add your onTap functionality here
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => Transportation(
                            //         phone: widget.phone,
                            //         language: widget.language),
                            //   ),
                            // );
                          },
                          child: Stack(children: [
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
                                  child: isSelected
                                      ? translate(
                                          'Next',
                                          TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : translate(
                                          'Skip',
                                          TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )

                                  // Text(
                                  //   isSelected ? 'Next' : 'Skip',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                  ),
                            )
                          ]))))
            ])));
  }
}
