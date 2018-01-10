import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/ProfilePageComponents/UserPage.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/LoginUtils.dart';

class ProfileWrapper extends StatefulWidget {

  @override
  _ProfileWrapperState createState() => new _ProfileWrapperState();
}

class _ProfileWrapperState extends State<ProfileWrapper> {
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


    return new Scaffold(
      appBar: new AppBar(title: new Text("Profile"),),
      drawer: new AppDrawer(logOut: logOut),
      body: this.user != null ? new UserPage(currentUser: user,) : new Center(child: new CircularProgressIndicator(),),
    );
  }
}