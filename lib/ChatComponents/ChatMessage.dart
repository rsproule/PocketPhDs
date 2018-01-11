import 'dart:async';
import 'dart:ui' as ui;

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
      @required this.currentUser});

  final DataSnapshot snapshot;
  final Animation animation;
  final User currentUser;

  @override
  _ChatMessageState createState() => new _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  int _determineNullCount(String a, String b) {
    int count = 0;
    if (a == null) count++;
    if (b == null) count++;

    return count;
  }

  Widget _getWidget(List<Widget> widgets) {
    for (Widget w in widgets) {
      if (w != null) {
        return w;
      }
    }
    return null;
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
    bool messageIsSent = widget.snapshot.value['isSent'];

    // dont display anything if this isnt curr user's message
    if (!messageIsSent && !isCurrentUserMessage) {
      return new Container();
    }

    // null if the user just sent an image or file
    String message = widget.snapshot.value['message'];
    message = message == "" ? null : message;
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
    String thumbnailLink = widget.snapshot.value['thumbnail'];

    Widget image;
    if(imageLink != null) {
      image = _getImage(imageLink, thumbnailLink, isCurrentUserMessage);
    }
    listOfWidgets.add(image);

    // check how many of the possible widgets are null,
    // if there is only one then dont put it inside a column
    // this ensures that the bubble wraps tightly
    int nullCount = _determineNullCount(message, imageLink);
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

    if (nullCount > 0) {
      messageContent = _getWidget(listOfWidgets);
    } else {
      messageContent = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          image != null ? image : new Container(),
          text != null ? text : new Container(),
        ],
      );
    }
    //TODO display the image and text in seperate containers
    if (messageContent != null) {
      return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: widget.animation, curve: Curves.easeOut),
        child: new MessageWrapper(
            isOnlyPhoto: (image != null && nullCount ==  1),
            myMessage: isCurrentUserMessage,
            child: messageContent,
            name: new Text(name),
            time: time),
      );
    } else {
      return new Container();
    }
  }

  Widget _getImage(String imageUrl, String thumbnailUrl, bool myMessage) {
    final Radius radius = const Radius.circular(15.0);
    final Radius noRadius = const Radius.circular(0.0);

    // in process of uploading image still
    if (imageUrl == null && myMessage) {
      return new Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: myMessage ? radius : noRadius,
              bottomRight: myMessage ? noRadius : radius),
        ),
//              child: new FadeInImage(
//                  placeholder: new AssetImage("images/loader.gif"),
//                  image: new NetworkImage(thumbnailUrl)
//              ),
        child: new Text("Uploading..."),
      );
    }

    // case 2b: image has uploaded but thumbnail has not generated yet
    if (thumbnailUrl == null && imageUrl != null) {
      thumbnailUrl = imageUrl;
      //automatically bleeds into the next
    }

    //everything has sent and is in the database
    if (thumbnailUrl != null && imageUrl != null) {


      return new Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: new GestureDetector(
          onTap: () {
            showPhoto(context, new NetworkImage(imageUrl), imageUrl);
          },
          child: new Hero(
            tag: imageUrl,
            child: new Container(
              foregroundDecoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new NetworkImage(thumbnailUrl),
                  fit: BoxFit.fill,
                ),
                borderRadius: new BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomLeft: myMessage ? radius : noRadius,
                    bottomRight: myMessage ? noRadius : radius),
              ),


//              child: new FadeInImage(
//                  placeholder: new AssetImage("images/loader.gif"),
//                  image: new NetworkImage(thumbnailUrl),
//
////                  fit: BoxFit.fill,
//
//              ),
            child: new Container(height: 140.0,),
            ),
          ),
        ),
      );
    }

    return null;
  }
}

class MessageWrapper extends StatelessWidget {
  const MessageWrapper(
      {@required this.child,
      @required this.myMessage,
      this.name,
      this.time,
        this.isOnlyPhoto
      });

  final Widget child;
  final bool myMessage;
  final Widget name;
  final Widget time;
  final bool isOnlyPhoto;
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
              padding: !this.isOnlyPhoto ? const EdgeInsets.all(10.0) : null,
              margin:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              constraints: new BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2),
              decoration: !this.isOnlyPhoto
                  ? new BoxDecoration(
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
                    )
                  : null,
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
