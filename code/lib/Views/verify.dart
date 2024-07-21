// verify.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:roti_kapda_makan/Views/language.dart';
import 'package:roti_kapda_makan/Views/user_details.dart';
import 'location.dart';
import 'dart:async';

class MyVerify extends StatefulWidget {
  final String verificationid;
  final String phone;

  const MyVerify(
      {super.key, required this.verificationid, required this.phone});

  @override
  _MyVerifyState createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  List<TextEditingController> otpController =
      List<TextEditingController>.generate(
          6, (index) => TextEditingController());
  String? otpcode;
  int minutes = 0;
  int seconds = 30;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  bool isWithin60Seconds(DateTime creationTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(creationTime);
    int differenceInSeconds = difference.inSeconds.abs();
    return differenceInSeconds <= 180;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (minutes > 0 || seconds > 0) {
          if (seconds == 0) {
            minutes--;
            seconds = 59;
          } else {
            seconds--;
          }
        } else {
          // Timer reached 0:00, you can perform actions here if needed
          // timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // Show the alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return an alert dialog
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            // Add a button to close the dialog
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

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
                                color: Color(0xFF3D2EF5),
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

                // OTP verification text box
                const Positioned(
                    top: 314,
                    left: 126,
                    child: Text(
                      'OTP Verification',
                      style: TextStyle(
                        color: Color(0xFF5E5E62),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 0.07,
                      ),
                    )),

                // Enter code box
                const Positioned(
                    top: 354,
                    left: 63,
                    child: SizedBox(
                      width: 283,
                      child: Text(
                        'Enter the code from the sms',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5E5E62),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0.07,
                        ),
                      ),
                    )),

                Positioned(
                    top: 374,
                    left: 70,
                    child: SizedBox(
                      width: 270,
                      child: Text(
                        "we sent to ${widget.phone}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5E5E62),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0.07,
                        ),
                      ),
                    )),
                // Timer box
                Positioned(
                  top: 437,
                  left: 179,
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Color(0xFF6255FF),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 0.07,
                    ),
                  ),
                ),

                Positioned(
                  top: 473,
                  left: 47,
                  child: Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 43,
                      height: 63,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.purple.shade50,
                          )),
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onCompleted: (value) {
                      setState(() {
                        otpcode = value;
                      });
                    },
                  ),
                ),

                Positioned(
                  top: 572,
                  left: 63,
                  child: SizedBox(
                    width: 283,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Didn\'t receive OTP? ',
                            style: TextStyle(
                              color: Color(0xFF5E5E62),
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 0.07,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Handle resend button press
                              if (seconds == 0) {
                                FirebaseAuth auth = FirebaseAuth.instance;

                                await auth.verifyPhoneNumber(
                                  phoneNumber: widget.phone,
                                  timeout: const Duration(seconds: 30),
                                  verificationCompleted:
                                      (PhoneAuthCredential credential) async {
                                    await auth.signInWithCredential(credential);
                                  },
                                  verificationFailed:
                                      (FirebaseAuthException e) {
                                    if (e.code == 'invalid-phone-number') {
                                      print(
                                          'The provided phone number is not valid.');
                                    }
                                  },
                                  codeSent: (String verificationid,
                                      int? resendToken) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyVerify(
                                              verificationid: verificationid,
                                              phone: widget.phone)),
                                    );
                                  },
                                  codeAutoRetrievalTimeout:
                                      (String verificationId) {},
                                );
                              }
                            },
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: seconds != 0
                                    ? Colors.grey
                                    : Color(0xFF3D2EF5),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                height: 0.07,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Next box

                Positioned(
                  width: 160,
                  height: 56,
                  top: 654,
                  left: 125,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                          verificationId: widget.verificationid,
                          smsCode: otpcode!,
                        );
                        await FirebaseAuth.instance
                            .signInWithCredential(credential);

                        FirebaseAuth _auth = FirebaseAuth.instance;

                        User? user = _auth.currentUser;
                        DateTime? creationTime = user?.metadata.creationTime;
                        bool check = isWithin60Seconds(creationTime!);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectLanguage(
                                    phone: widget.phone,
                                    language: '',
                                    check:check
                                  )),
                          // );
                          // } else {
                          //   // User has signed in again
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => SelectLanguage(phone: widget.phone,language:'language',)),
                        );
                        // }
                      } catch (e) {
                        showAlertDialog(
                          context,
                          'Alert',
                          'Invalid OTP! Please try again.',
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
            )));
  }
}
