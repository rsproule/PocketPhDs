import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/Login.dart';
import 'package:pocketphds/User.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User> getUser(FirebaseUser fbUser) async {
  DatabaseReference userRef =
      FirebaseDatabase.instance.reference().child("users").child(fbUser.uid);

  DataSnapshot snapshot = await userRef.once();
  String name = snapshot.value['name'];
  UserType type = convertStringToUserType(snapshot.value['type']);
  String chatId = snapshot.value['chat'];
  String email = snapshot.value['email'];
  Map<String, dynamic> student = snapshot.value['student'];
  return new User(
      name: name,
      userID: fbUser.uid,
      type: type,
      chatId: chatId,
      email: email,
      firebase_user: fbUser,
      students: student
  );
}

Future<FirebaseUser> loginDialog(BuildContext context) async {
  FirebaseUser user =
      await Navigator.of(context).push(new MaterialPageRoute<FirebaseUser>(
            builder: (BuildContext context) {
              return new LoginDialog();
            },
            fullscreenDialog: true,
          ));
  return user;
}

// silent login to see if we have a current user
Future<FirebaseUser> ensureLoggedIn(FirebaseUser currentUser, BuildContext context) async {
  if (currentUser == null) {
    currentUser = await _auth.currentUser();
  }
  if (currentUser == null) {
    currentUser = await loginDialog(context);
  }
  final analytics = new FirebaseAnalytics();     // new
  analytics.logLogin();
  return currentUser;
}