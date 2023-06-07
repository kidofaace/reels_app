import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';
import 'package:reel_app/main_menu.dart';

class login extends StatefulWidget {
  @override
  static String verify = "";
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  String country_no = '+91';
  TextEditingController _phoneNumberController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => mainmenu(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reels App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Log-in'),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                    hintText: 'Phone Number', prefix: Text(country_no)),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 10) {
                    return 'It must be 10 characters.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber:
                          country_no + _phoneNumberController.text.trim(),
                      verificationCompleted:
                          (PhoneAuthCredential credential) async {
                        await auth.signInWithCredential(credential);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('OTP SENT')));
                      },
                      verificationFailed: (FirebaseAuthException e) {
                        if (e.code == 'invalid-phone-number') {
                          print('The provided phone number is not valid.');
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid phone number')));
                        }
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        login.verify = verificationId;
                        Navigator.pushNamed(context, "otp");
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                  },
                  child: Text('Get Otp')),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Future<void> eVerify() async {
//   String phone_no = '+91' + _phoneNumberController.text.trim();
//
//   await auth.verifyPhoneNumber(
//       phoneNumber: phone_no,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await auth.signInWithCredential(credential);
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('login successful')));
//       },
//       verificationFailed: (FirebaseAuthException exception) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('error')));
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         Navigator.pushNamed(context, "otp");
//         setState(() {
//           _verificationID = verificationId;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         setState(() {
//           _verificationID = verificationId;
//         });
//       },
//       timeout: Duration(seconds: 60));
// }
}
