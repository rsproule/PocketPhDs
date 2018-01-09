import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ChatComponents/Chat.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/User.dart';

class StudentChat extends StatefulWidget {
  StudentChat({@required this.user});

  User user;

  @override
  _StudentChatState createState() => new _StudentChatState();
}

class _StudentChatState extends State<StudentChat> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Chat(currentUser: widget.user, chatKey: widget.user.chatId);
  }
}
