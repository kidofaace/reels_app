import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';
import 'package:reel_app/authentication.dart';

class otp extends StatefulWidget {
  const otp({super.key});

  @override
  State<otp> createState() => _otpState();
}

class _otpState extends State<otp> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    PinTheme(
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

    var code = '';
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP screen'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Pinput(
              length: 6,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onChanged: (value) {
                code = value;
              },
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider
                        .credential(
                        verificationId: login.verify, smsCode: code);

                    // Sign the user in (or link) with the credential
                    await auth.signInWithCredential(credential);
                    Navigator.pushNamedAndRemoveUntil(context, "mainmenu", (route) => false);
                  }
                  catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('invalid OTP')));
                  }
                },
                child: Text('Verify'))
          ],
        ),
      ),
    );
  }
}
