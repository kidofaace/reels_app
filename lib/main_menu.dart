import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reel_app/authentication.dart';

class mainmenu extends StatefulWidget {
  @override
  State<mainmenu> createState() => _mainmenuState();
}

class _mainmenuState extends State<mainmenu> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reels',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Upload reels'),
            onTap: () {
              Navigator.pushNamed(context, 'upload');
            },
          ),
          ListTile(
            leading: Icon(Icons.play_circle),
            title: Text('Watch reels'),
            onTap: () {
              Navigator.pushNamed(context, 'watch');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('log out'),
            onTap: () {
              auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => login(),
                ),
              );
            },
          ),

          // ListTile(
          //   leading: Icon(Icons.verified_user_outlined),
          //   title: Text('Authenticate'),
          //   onTap: (){
          //     MaterialApp.router(login);
          //   },
          // )
        ],
      ),
    );
  }
}
