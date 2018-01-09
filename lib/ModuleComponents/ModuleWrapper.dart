import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/ModuleComponents/LessonsPage.dart';
import 'package:pocketphds/ModuleComponents/ParentModulePage.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/LoginUtils.dart';

class ModuleWrapper extends StatefulWidget {
  ModuleWrapper({this.scaffoldKey});

final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  _ModuleWrapperState createState() => new _ModuleWrapperState();
}

class _ModuleWrapperState extends State<ModuleWrapper> {
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
      ensureLoggedIn(currentUser, context).then((FirebaseUser fbUser) {
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
    Map<UserType, Widget> widgets = {
      UserType.student: new LessonsPage(currentUser: user),
      UserType.tutor: new Container(
        child: new Center(
          child: new Text("No Module Data for tutors"),
        ),
      ),
      UserType.parent: new ParentModulePage(currentUser: user,),
      UserType.teacher: new Container()
    };

    return new Scaffold(
      key: widget.scaffoldKey,
      appBar: new AppBar(
        title: new Text("Brain Modules"),
      ),
      drawer: new AppDrawer(logOut: logOut),
      body: this.user != null
          ? widgets[user.type]
          : new Center(
              child: new CircularProgressIndicator(),
            ),
    );
  }
}
