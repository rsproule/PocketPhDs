import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ChatComponents/ChatWrapper.dart';
import 'package:pocketphds/Homepages/HomeWrapper.dart';
import 'package:pocketphds/ModuleComponents/ModuleWrapper.dart';

import 'package:pocketphds/ProfilePageComponents/ProfileWrapper.dart';
import 'package:pocketphds/utils/LoginUtils.dart';


void main() => runApp(new MyHomePage());

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseUser currentUser;


  void initState(){
    super.initState();



    /// Initialize the notification system
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        String msg = message['alert']['body'];
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text("New Chat: $msg"),
            action: new SnackBarAction(
                label: "View",
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("/chat");
                })));
      },
      onLaunch: (Map<String, dynamic> message) {
        Navigator.of(context).pushReplacementNamed("/chat");
      },
      onResume: (Map<String, dynamic> message) {
        Navigator.of(context).pushReplacementNamed("/chat");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    // This is the only part that need the user id
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      ensureLoggedIn(currentUser, context).then((fbUser){
        // update the database to hold the user specific notification token
        FirebaseDatabase.instance.reference().child("users").child(fbUser.uid).child("notificationToken").set(token);
      });
    });



  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
          primarySwatch: Colors.blueGrey,
          backgroundColor: Colors.blue.withOpacity(.4),
      ),
      home: new Home(),
      routes: <String, WidgetBuilder>{
        '/chat': (BuildContext context) => new ChatWrapper(scaffoldKey: _scaffoldKey),
        '/modules': (BuildContext context) => new ModuleWrapper(scaffoldKey: _scaffoldKey),
        '/profile': (BuildContext context) => new ProfileWrapper(scaffoldKey: _scaffoldKey)
      },
    );
  }
}
