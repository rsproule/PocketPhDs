import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ChatComponents/ChatPages/ParentChat.dart';
import 'package:pocketphds/ChatComponents/ChatPages/StudentChat.dart';
import 'package:pocketphds/ChatComponents/ChatPages/TutotChat.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/LoginUtils.dart';

class ChatWrapper extends StatefulWidget {


  @override
  _ChatWrapperState createState() => new _ChatWrapperState();
}

class _ChatWrapperState extends State<ChatWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

// The user instance that the app should be displaying for
  FirebaseUser currentUser;
  User user;


  Future<bool> logOut() async {
    await _auth.signOut();

    setState(() {
      user = null;
      currentUser = null;
    });

    return true;
  }

  StreamSubscription authListener;

  @override
  initState() {
    super.initState();
    authListener = _auth.onAuthStateChanged.listen((user) {
      ensureLoggedIn(currentUser, context).then((fbUser) {
        if (fbUser != null) {
          getUser(fbUser).then((myUser) {
            setState(() {
              this.user = myUser;
            });
          });
        }
      });
    });
  }

  @override
  dispose() {
    //dispose of listeners
    authListener.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Map holding the right widget for each different type
    Map<UserType, Widget> widgets = {
      UserType.student: new StudentChat(user: user),
      UserType.tutor: new TutorChat(currentUser : user),
      UserType.parent: new ParentChat(currentUser: user),
      UserType.teacher: new Container()
    };

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Chat"),
        ),
        drawer: new AppDrawer(
          logOut: logOut,
        ),
        body: user != null
            ? widgets[user.type]
            : new Center(
                child: new CircularProgressIndicator(),
              ));
  }
}
