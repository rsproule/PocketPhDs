import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketphds/ChatComponents/ChatMessage.dart';
import 'package:pocketphds/ChatComponents/MessageComposer.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/chatUtils.dart';

class Chat extends StatefulWidget {
  Chat(
      {@required this.currentUser,
      @required this.chatKey,
      this.canEdit = true});

  final String chatKey;
  final User currentUser;
  bool canEdit;

  @override
  _ChatState createState() => new _ChatState();
}

class _ChatState extends State<Chat> {


  bool _onScroll(ScrollUpdateNotification n) {
    // if the scroll is beyond a certain point trigger this

    // // print(n.metrics.outOfRange);

    if (n.metrics.extentBefore > 30.0) {
      // this changes the focus away from the text field..
      // causes the keyboard to close
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    return true;
  }




  @override
  Widget build(BuildContext context) {
    DatabaseReference _messagesRef = FirebaseDatabase.instance
        .reference()
        .child("messages")
        .child(widget.chatKey);

    return new Column(
      children: <Widget>[
        new Flexible(
          child: new NotificationListener<ScrollUpdateNotification>(
              onNotification: _onScroll,
              child: new FirebaseAnimatedList(
                  sort: sortByTime,
                  primary: true,
                  query: _messagesRef,
                  reverse: true,
                  itemBuilder: (_, snapshot, animation, i) {
                    return new ChatMessage(
                        snapshot: snapshot,
                        animation: animation,
                        currentUser: widget.currentUser);

                  })),
        ),
        new Divider(
          height: 0.0,
        ),
        widget.canEdit
            ? new MessageComposer(
                chatKey: widget.chatKey,
                currentUser: widget.currentUser,
              )
            : new Container()
      ],
    );
  }
}
