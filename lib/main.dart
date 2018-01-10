import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ChatComponents/ChatWrapper.dart';
import 'package:pocketphds/Homepages/HomeWrapper.dart';
import 'package:pocketphds/ModuleComponents/ModuleWrapper.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';

import 'package:pocketphds/ProfilePageComponents/ProfileWrapper.dart';
import 'package:pocketphds/utils/LoginUtils.dart';

void main() => runApp(new MyHomePage());

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

//  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseUser currentUser;

  modal(String message, String route) {
    showModalBottomSheet<Null>(
        context: context,
        builder: (BuildContext context) {
          return new Container(
              child: new Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text("New Chat: Hey man",
                            textAlign: TextAlign.left),
                      ),
                      new PlatformButton(
                        child: new Text("View"),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(route);
                        },
                      )
                    ],
                  )));
        });
  }

  void initState() {
    super.initState();

    /// Initialize the notification system
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        String msg = message['alert']['body'];
        String head = message['alert']['title'];
        if (head == "New Chat Message") {
          modal(msg, '/chat');
        } else {
          modal(msg, '/modules');
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        String head = message['alert']['title'];
        if (head == "New Chat Message") {
          Navigator.of(context).pushReplacementNamed("/chat");
        } else {
          Navigator.of(context).pushReplacementNamed("/modules");
        }
      },
      onResume: (Map<String, dynamic> message) {
        String head = message['alert']['title'];
        if (head == "New Chat Message") {
          Navigator.of(context).pushReplacementNamed("/chat");
        } else {
          Navigator.of(context).pushReplacementNamed("/modules");
        }
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    // This is the only part that need the user id
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      ensureLoggedIn(currentUser, context).then((fbUser) {
        // update the database to hold the user specific notification token
        FirebaseDatabase.instance
            .reference()
            .child("users")
            .child(fbUser.uid)
            .child("notificationToken")
            .set(token);
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
        '/chat': (BuildContext context) => new ChatWrapper(),
        '/modules': (BuildContext context) => new ModuleWrapper(),
        '/profile': (BuildContext context) => new ProfileWrapper()
      },
    );
  }
}
