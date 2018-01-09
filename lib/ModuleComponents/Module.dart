import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class Module {
  Module({@required this.name,
    @required this.description,
    @required this.quizTaken,
    @required this.videoWatched,
    @required this.key,
    @required this.currentUserId,
    @required this.dueDate,
    @required this.questionCount,
    @required this.responses
  });

  final String name;
  final String description;
  bool videoWatched;
  bool quizTaken;
  final String key;
  final String currentUserId;
  final DateTime dueDate;
  final int questionCount;
  final List responses;

  Future<bool> updateVideoWatched() async {
    final DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(this.currentUserId)
        .child("modules")
        .child(this.key);

    await ref.child("videoWatched").set(true);
    return true;
  }

  Future<bool> updateQuizTaken() async {
    final DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(this.currentUserId)
        .child("modules")
        .child(this.key);

    await ref.child("quizTaken").set(true);
    return true;
  }
}
