import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/Homepages/ParentHomePage.dart';
import 'package:pocketphds/Homepages/StudentHomePage.dart';
import 'package:pocketphds/Homepages/TutorHomePage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/LoginUtils.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  // The user instance that the app should be displaying for
  FirebaseUser currentUser;
  User user;

  Future<bool> logOut() async {
    await _auth.signOut();

    setState(() {
      user = null;
      currentUser = null;
    });
    ensureLoggedIn(currentUser, context).then((fbUser) {
      if (fbUser != null) {
        getUser(fbUser).then((myUser) {
          setState(() {
            this.user = myUser;
          });
        });
      }
    });
    return true;
  }

  StreamSubscription authListener;

  @override
  initState() {
    super.initState();
//    authListener = _auth.onAuthStateChanged.listen((user) {
      ensureLoggedIn(currentUser, context).then((fbUser) {
        if (fbUser != null) {
          getUser(fbUser).then((myUser) {
            setState(() {
              this.user = myUser;
            });
          });
        }
      });
//    });

  }

  @override
  dispose() {
    //dispose of listeners
//    authListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Map holding the right widget for each different type
    Map<UserType, Widget> widgets = {
      UserType.student: new StudentView(currentUser: user),
      UserType.tutor: new TutorHomePage(currentUser: user),
      UserType.parent: new ParentHomePage(currentUser: user),
      UserType.teacher: new Container(
        child: new Center(
          child: new Text(
            "Teacher mobile app not available. Find your class on the web at PocketPhDs.com.",
            style: Theme.of(context).textTheme.title,
          ),
        ),
      )
    };

    return new Scaffold(
        drawer: new AppDrawer(
          logOut: logOut,
        ),
        body: this.user != null
            ? widgets[user.type]
            : new Center(
                child: new CircularProgressIndicator(),
              ));
  }
}
