import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketphds/ImageView.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/chatUtils.dart';

class ChatMessage extends StatefulWidget {
  ChatMessage(
      {@required this.snapshot,
      @required this.animation,
      @required this.currentUser,
      this.thumbnail,
      this.image});

  final DataSnapshot snapshot;
  final Animation animation;
  final User currentUser;
  final Uint8List thumbnail;
  final Uint8List image;

  @override
  _ChatMessageState createState() => new _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  int _determineNullCount(String a, String b, String c) {
    int count = 0;
    if (a == null) count++;
    if (b == null) count++;
    if (c == null) count++;

    return count;
  }

  Widget _getWidget(List<Widget> widgets) {
    for (Widget w in widgets) {
      if (w != null) {
        return w;
      }
    }
    return new Text(
      "Error",
      style: new TextStyle(color: Colors.red),
    );
  }

  void showPhoto(BuildContext context, ImageProvider image, String tag) {
    Navigator.push(
      context,
      new MaterialPageRoute<Null>(
          fullscreenDialog: true,
          maintainState: true,
          builder: (BuildContext context) {
            return new Scaffold(
              appBar: new AppBar(
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: Colors.black,
              body: new SizedBox.expand(
                child: new Hero(
                  tag: tag,
                  child: new ImageView(image: image),
                ),
              ),
            );
          }),
    );
  }

  _copyMessageDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Copy Message?"),
          actions: [
            new PlatformButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new PlatformButton(
                child: new Text("Copy"),
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: message));
                  Navigator.of(context).pop();


                })
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listOfWidgets = [];

    // determine who the message is from, for displaying differences
    Map<String, dynamic> sender = widget.snapshot.value['sender'];
    bool isCurrentUserMessage = sender["id"] == widget.currentUser.userID;

    // null if the user just sent an image or file
    String message = widget.snapshot.value['message'];
    Widget text = message != null
        ? new GestureDetector(
            onLongPress: () {
              _copyMessageDialog(context, message);
            },
            child: new Text(message))
        : null;
    listOfWidgets.add(text);

    // null if regular text message
    String imageLink = widget.snapshot.value['image'];
    Widget image = imageLink != null
        ? widget.thumbnail != null
            ? new Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                child: new GestureDetector(
                    onTap: () {
                      showPhoto(
                          context,
                          new MemoryImage(widget.image != null
                              ? widget.image
                              : widget.thumbnail),
                          imageLink);
                    },
                    child: new Hero(
                      tag: imageLink,
                      child: new FadeInImage(
                          placeholder: new AssetImage("images/loader.gif"),
                          image: new MemoryImage(widget.thumbnail)),
                    )))
            : new Image.asset("images/loader.gif")
        : null;

    listOfWidgets.add(image);

    // null if there is no file attachment
    String fileLink = widget.snapshot.value['file'];
    Widget file = fileLink != null ? new Text("FILE NOT IMPLEMENTED") : null;
    listOfWidgets.add(file);

    // check how many of the possible widgets are null,
    // if there is only one then dont put it inside a column
    int nullCount = _determineNullCount(message, imageLink, fileLink);

    //sender information
    String name = widget.snapshot.value['sender']['name'];
//    String senderId = widget.snapshot.value['sender']['id'];
//    String profileURL = widget.currentUser.firebase_user.photoUrl;
    // TODO use this guy in the ui
//    Widget profAvatar = new CircleAvatar(
//      child: profileURL != null
//          ? new Image.network(profileURL)
//          : new Text(name.substring(0, 1).toUpperCase()),
//    );

    //timestamp
    DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(
        widget.snapshot.value['timestamp']);
    Widget time = new Text(convertToTimeString(timestamp));

    Widget messageContent;
    if (nullCount > 1) {
      messageContent = _getWidget(listOfWidgets);
    } else {
      messageContent = new Column(
        children: <Widget>[
          image != null ? image : new Container(),
          file != null ? file : new Container(),
          text != null ? text : new Container(),
        ],
      );
    }

    return new SizeTransition(
      sizeFactor:
          new CurvedAnimation(parent: widget.animation, curve: Curves.easeOut),
      child: new MessageWrapper(
          myMessage: isCurrentUserMessage,
          child: messageContent,
          name: new Text(name),
          time: time),
    );
  }
}

class MessageWrapper extends StatelessWidget {
  const MessageWrapper(
      {@required this.child, @required this.myMessage, this.name, this.time});

  final Widget child;
  final bool myMessage;
  final Widget name;
  final Widget time;

  final Radius radius = const Radius.circular(15.0);
  final Radius noRadius = const Radius.circular(0.0);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        time,
        new Row(
          children: <Widget>[
            this.myMessage
                ? new Expanded(child: new Container())
                : new Container(),
            new Container(
              margin: const EdgeInsets.only(
                  left: 10.0, top: 5.0, right: 10.0, bottom: 2.0),
              child: name,
            ),
            !this.myMessage
                ? new Expanded(child: new Container())
                : new Container(),
          ],
        ),
        new Row(
          children: <Widget>[
            this.myMessage
                ? new Expanded(child: new Container())
                // leading on not my message
                : new Container(),

//

            // Text content Bubble
            new Container(
              padding: const EdgeInsets.all(10.0),
              margin:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              constraints: new BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2),
              decoration: new BoxDecoration(
                color: this.myMessage
                    ? Theme.of(context).backgroundColor
                    : Colors.black12,
                border: new Border.all(
                  width: 1.0,
                  color: Colors.black12,
                ),
                borderRadius: new BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomLeft: this.myMessage ? radius : noRadius,
                    bottomRight: this.myMessage ? noRadius : radius),
              ),
              child: this.child,
            ),

            !this.myMessage
                ? new Expanded(child: new Container())
                : new Container(),
          ],
        ),
      ],
    );
  }
}
