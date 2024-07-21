import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'verify.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({super.key, required String phone});

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  final TextEditingController phoneController = TextEditingController();
  Country selectedCountry = Country(
      phoneCode: "91",
      countryCode: "IN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "India",
      example: "India",
      displayName: "India",
      displayNameNoCountryCode: "IN",
      e164Key: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 410,
        height: 899,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
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
            // three dot box
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
                            color: Color(0xFF3D2EF5),
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
                      // Guardian Angel box
                      Positioned(
                        left: 52,
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
                    ],
                  ),
                )),
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
                            image: AssetImage("assets/image3.png"),
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

            //  Enter mobile number and login text
            const Positioned(
              width: 310,
              height: 26,
              top: 365,
              left: 32,
              child: Text(
                'Enter mobile number and login',
                style: TextStyle(
                  color: Color(0xFF5E5E62),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 0.07,
                ),
              ),
            ),

            //Enter Mobile number
            Positioned(
                width: 346,
                height: 63,
                top: 397,
                left: 32,
                // Other widgets can be added here
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.purple,
                  controller: phoneController,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      hintText: 'Mobile number',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(width: 1.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1.35, color: Color.fromRGBO(76, 73, 159, 1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                                context: context,
                                countryListTheme: const CountryListThemeData(
                                    bottomSheetHeight: 550),
                                onSelect: (value) {
                                  setState(() {
                                    selectedCountry = value;
                                  });
                                });
                          },
                          child: Text(
                              "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                              style: const TextStyle(
                                  fontSize: 18,
                                  height: 2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )),
                )),

            // Next Button
            Positioned(
              width: 160,
              height: 56,
              top: 578,
              left: 125,
              child: ElevatedButton(
                onPressed: () async {
                  
                  FirebaseAuth auth = FirebaseAuth.instance;
                  
                  await auth.verifyPhoneNumber(
                    phoneNumber:
                        "+${selectedCountry.phoneCode.toString()}${phoneController.text.toString()}",
                    timeout: const Duration(seconds: 30),
                    verificationCompleted:
                        (PhoneAuthCredential credential) async {
                      await auth.signInWithCredential(credential);
                    },
                    verificationFailed: (FirebaseAuthException e) {
                      if (e.code == 'invalid-phone-number') {
                        print('The provided phone number is not valid.');
                      }
                    },
                  
                    codeSent: (String verificationid, int? resendToken) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyVerify(
                                  verificationid: verificationid,
                                  phone: "+${selectedCountry.phoneCode.toString()}${phoneController.text.toString()}"
                                )),
                      );
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {},
                  );
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
                      const Positioned.fill(
                        top: 16,
                        child: Text(
                          'Next',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
}
