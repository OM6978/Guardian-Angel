import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:roti_kapda_makan/Views/language.dart';
import 'package:roti_kapda_makan/Views/location.dart';
import 'package:translator/translator.dart';

class SignUp extends StatefulWidget {
  String phone;
  final String language;

  SignUp({super.key, required this.phone, required this.language});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _FirstName = TextEditingController();
  // final TextEditingController _Gender = TextEditingController();
  final TextEditingController _LastName = TextEditingController();
  String FirstName = '';
  String LastName = '';
  String? Gender;

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  final translator = GoogleTranslator();

  Future<String> _translateText(String text, {String toLanguage = 'en'}) async {
    Translation translation = await translator.translate(text, to: toLanguage);
    return translation.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  FutureBuilder<String>(
                    future:
                        _translateText('Sign up', toLanguage: widget.language),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Color(0xFF3D2EF5),
                            fontSize: 36,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
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
                  ),
                  SizedBox(height: 30.0),
                  FutureBuilder<String>(
                    future: _translateText('First name',
                        toLanguage: widget.language),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Color(0xFF5E5E62),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
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
                  ),
                  TextFormField(
                    controller: _FirstName,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Color(0xFFB8B2FC), width: 1.35),
                      ),
                      hintText: 'Enter your first name',
                      hintStyle: TextStyle(
                        color: Color(0xFFC6C6C6),
                        fontFamily: 'Poppins',
                        fontSize: 15.32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  FutureBuilder<String>(
                    future: _translateText('Last name',
                        toLanguage: widget.language),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Color(0xFF5E5E62),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
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
                  ),
                  TextFormField(
                    controller: _LastName,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Color(0xFFB8B2FC), width: 1.35),
                      ),
                      hintText: 'Enter your last name',
                      hintStyle: TextStyle(
                        color: Color(0xFFC6C6C6),
                        fontFamily: 'Poppins',
                        fontSize: 15.32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  FutureBuilder<String>(
                    future: _translateText('Date of birth',
                        toLanguage: widget.language),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Color(0xFF5E5E62),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
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
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Color(0xFFB8B2FC), width: 1.35),
                            ),
                            hintText: 'DD/MM/YYYY',
                            hintStyle: TextStyle(
                              color: Color(0xFFC6C6C6),
                              fontFamily: 'Poppins',
                              fontSize: 15.32,
                              fontWeight: FontWeight.w400,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => _selectDate(context),
                              icon: ImageIcon(
                                AssetImage('assets/calendar.png'),
                                color: Color(0xFF3D2EF5),
                              ),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.0),
                  FutureBuilder<String>(
                    future:
                        _translateText('Gender', toLanguage: widget.language),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Color(0xFF5E5E62),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
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
                  ),
                  Column(
                    children: [
                      Container(
                        width: 350,
                        height: 60,
                        padding: const EdgeInsets.only(left: 16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(width: 1, color: Color(0xFFACA5FF)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _translateText(Gender ?? 'Select',
                                    toLanguage: widget.language),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 84, 83, 83)),
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
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: ImageIcon(
                                AssetImage(
                                    'assets/dropdown_arrow.png'), // Replace with the correct path
                                size: 22, // Adjust size as needed
                                color: Color.fromARGB(
                                    238, 89, 88, 88), // Adjust color as needed
                              ),
                              itemBuilder: (BuildContext context) {
                                return <PopupMenuEntry<String>>[
                                  for (String value in [
                                    'Male',
                                    'Female',
                                    'Others'
                                  ])
                                    PopupMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                ];
                              },
                              onSelected: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    Gender = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 80.0),
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Implement your submission logic here
                          FirstName = _FirstName.text;
                          LastName = _LastName.text;

                          try {
                            final uri = Uri.parse(
                                "http://192.168.33.248:6174/upload_user_details");
                            Map<String, dynamic> request = {
                              "firstName": FirstName,
                              "lastName": LastName,
                              "dob": _selectedDate.toString(),
                              "gender": Gender,
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
                                      language: languageCode,
                                    )),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF3D2EF5)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          alignment: Alignment.center,
                          child: FutureBuilder<String>(
                            future: _translateText('Next',
                                toLanguage: widget.language),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Cabin',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}




// class UserDetails extends StatefulWidget {
//   final String phone;

//   const UserDetails({Key? key, required this.phone}) : super(key: key);

//   @override
//   State<UserDetails> createState() => _UserDetailsState();
// }

// class _UserDetailsState extends State<UserDetails> {
//   TextEditingController _firstNameController = TextEditingController();
//   TextEditingController _lastNameController = TextEditingController();
//   TextEditingController _dobController = TextEditingController();
//   TextEditingController _genderController = TextEditingController();
//   TextEditingController _languageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _firstNameController,
//               decoration: InputDecoration(labelText: 'First Name'),
//             ),
//             TextField(
//               controller: _lastNameController,
//               decoration: InputDecoration(labelText: 'Last Name'),
//             ),
//             TextField(
//               controller: _dobController,
//               decoration: InputDecoration(labelText: 'Date of Birth'),
//             ),
//             TextField(
//               controller: _genderController,
//               decoration: InputDecoration(labelText: 'Gender'),
//             ),
//             TextField(
//               controller: _languageController,
//               decoration: InputDecoration(labelText: 'Language'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // Handle submit button press
//                 String firstName = _firstNameController.text;
//                 String lastName = _lastNameController.text;
//                 String dob = _dobController.text;
//                 String gender = _genderController.text;
//                 String language = _languageController.text;

//                 // Validate and process the data as needed

//                 // For now, just print the values
//                 try {
//                   final uri = Uri.parse(
//                       "http://192.168.33.248:6174/upload_user_details");
//                   Map<String, dynamic> request = {
//                     "firstName": firstName,
//                     "lastName": lastName,
//                     "dob": dob,
//                     "gender": gender,
//                     "language": language,
//                     "phone": widget.phone
//                   };
//                   final response =
//                       await http.post(uri, body: json.encode(request));
//                   print(response.body);
//                 } catch (e) {
//                   print(e);
//                 }

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => MyLocation(
//                             phone: widget.phone,
//                           )),
//                 );
//               },
//               child: Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
