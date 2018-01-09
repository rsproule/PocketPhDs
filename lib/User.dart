import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketphds/ModuleComponents/Module.dart';

class User {

  const User({
    @required this.name,
    @required this.userID,
    @required this.type,
    @required this.chatId,
    @required this.email,
    @required this.firebase_user,
    this.modules,
    this.students
  });


  final String name;
  final String userID;
  final UserType type;

  final String chatId;
  final String email;
  final Map<String, Module> modules;
  final FirebaseUser firebase_user;

  final Map<String, dynamic> students;



}

enum UserType {
  student,
  tutor,
  parent,
  teacher,
  none
}
UserType convertStringToUserType(String type){

  switch(type){
    case("student"):
      return UserType.student;
    case("parent"):
      return UserType.parent;
    case("teacher"):
      return UserType.teacher;
    case("tutor"):
      return UserType.tutor;
    default:
      return UserType.none;
  }

}
