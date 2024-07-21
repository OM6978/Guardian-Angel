import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roti_kapda_makan/Views/language.dart';
import 'package:roti_kapda_makan/Views/shelter.dart';
import 'package:roti_kapda_makan/Views/user_details.dart';
import 'Views/needy.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import './Views/phone.dart';
import './Views/verify.dart';
import './Views/location.dart';
import './Views/home.dart';
import './Views/edit_location.dart';
import './Views/validation.dart';
import './Views/clothes.dart';
import './Views/food.dart';
import './Views/transport.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'phone',
      // debugShowCheckedModeBanner: false,
      routes: {
        'phone': (context) => const MyPhone(phone: 'phone'),
        'language': (context) =>  SelectLanguage(phone: 'phone',language:'language',check:false),
        'validatiion':(context) =>  Validation(phone:'phone',language:'language'),
        'transport':(context) => Transportation(phone:'phone',language:'language',Selected:false),
        'verify': (context) =>
            const MyVerify(verificationid: 'verificationid', phone: 'phone'),
        'SignUp': ((context) =>  SignUp(phone: 'phone' ,language:'language')),
        'location': ((context) => const MyLocation(phone: 'phone' ,language:'language')),
        'home': ((context) => const HomePage(phone: 'phone',language: 'language')),
        'edit':(context) => MapScreen(currentLocation: null),
        'shelter': ((context) => MyShelter(
            phone: 'phone' ,language:'language' ,UserName: 'UserName', currentLocation: LatLng(0, 0))),
        'clothes': ((context) => MyClothes(
            phone: 'phone' ,language:'language', UserName: 'UserName', currentLocation:  LatLng(0, 0))),
        'food': ((context) => MyFood(
            phone: 'phone' ,language:'language', UserName: 'UserName', currentLocation:  LatLng(0, 0))),
        'needy': ((context) =>
            Needy(phone: 'phone' ,language:'language', UserName: 'UserName', currentLocation:  LatLng(0, 0))),
      },
    ); // MaterialApp
  }
}




// import 'package:flutter/material.dart';

// void main() {
//   runApp(const SignUp());
// }

// class SignUp extends StatelessWidget {
//   const SignUp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: Scaffold(
//         body: ListView(
//           padding: EdgeInsets.all(20.0),
//           children: [
//             SignUpForm(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SignUpForm extends StatefulWidget {
//   @override
//   _SignUpFormState createState() => _SignUpFormState();
// }

// class _SignUpFormState extends State<SignUpForm> {
//   final TextEditingController _dateController = TextEditingController();
//   DateTime? _selectedDate;

//   @override
//   void dispose() {
//     _dateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Sign up',
//           style: TextStyle(
//             color: Color(0xFF3D2EF5),
//             fontSize: 36,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         SizedBox(height: 20.0),
//         Text(
//           'First name',
//           style: TextStyle(
//             color: Color(0xFF5E5E62),
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         TextFormField(
//           style: TextStyle(color: Colors.black),
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Color(0xFFB8B2FC), width: 1.35),
//             ),
//             hintText: 'Enter your first name',
//             hintStyle: TextStyle(
//               color: Color(0xFFC6C6C6),
//               fontFamily: 'Poppins',
//               fontSize: 15.32,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//         SizedBox(height: 20.0),
//         Text(
//           'Last name',
//           style: TextStyle(
//             color: Color(0xFF5E5E62),
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         TextFormField(
//           style: TextStyle(color: Colors.black),
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Color(0xFFB8B2FC), width: 1.35),
//             ),
//             hintText: 'Enter your last name',
//             hintStyle: TextStyle(
//               color: Color(0xFFC6C6C6),
//               fontFamily: 'Poppins',
//               fontSize: 15.32,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//         SizedBox(height: 20.0),
//         Text(
//           'Date of birth',
//           style: TextStyle(
//             color: Color(0xFF5E5E62),
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _dateController,
//                 style: TextStyle(color: Colors.black),
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: BorderSide(color: Color(0xFFB8B2FC), width: 1.35),
//                   ),
//                   hintText: 'DD/MM/YYYY',
//                   hintStyle: TextStyle(
//                     color: Color(0xFFC6C6C6),
//                     fontFamily: 'Poppins',
//                     fontSize: 15.32,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: () => _selectDate(context),
//                     icon: ImageIcon(
//                       AssetImage('assets/calendar.png'),
//                       color: Color(0xFF3D2EF5),
//                     ),
//                   ),
//                 ),
//                 readOnly: true,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 20.0),
//         Text(
//           'Gender',
//           style: TextStyle(
//             color: Color(0xFF5E5E62),
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         DropdownButtonFormField<String>(
//           items: ['Male', 'Female', 'Other']
//               .map((String gender) => DropdownMenuItem<String>(
//                     value: gender,
//                     child: Text(gender),
//                   ))
//               .toList(),
//           onChanged: (String? value) {
//             // Handle gender selection
//           },
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Color(0xFFB8B2FC), width: 1.35),
//             ),
//             hintText: 'Select your gender',
//             hintStyle: TextStyle(
//               color: Color(0xFFC6C6C6),
//               fontFamily: 'Poppins',
//               fontSize: 15.32,
//               fontWeight: FontWeight.w400,
//             ),
//             suffixIcon: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: ImageIcon(
//                 AssetImage('assets/dropdown_arrow.png'),
//                 color: Color(0xFF3D2EF5),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 20.0),
//         ElevatedButton(
//           onPressed: () {
//             // Implement your submission logic here
//           },
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF3D2EF5)),
//             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//               RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//           ),
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(vertical: 15.0),
//             alignment: Alignment.center,
//             child: Text(
//               'Next',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontFamily: 'Cabin',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
