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
  Widget getMessageContent(){
    // determine who the message is from, for displaying differences
    Map<String, dynamic> sender = widget.snapshot.value['sender'];
    bool isCurrentUserMessage = sender["id"] == widget.currentUser.userID;
    bool messageIsSent = widget.snapshot.value['isSent'];
    String message = widget.snapshot.value['message'];
    String imageLink = widget.snapshot.value['image'];
    String thumbnailLink = widget.snapshot.value['thumbnail'];



    // nothing if is not sent but is current users message:
    if(!messageIsSent && isCurrentUserMessage){
      isOnlyImage = true;
      return new CircularProgressIndicator();
    }

    // if text only return the text only message:
    if(messageIsSent && imageLink == null){
      isOnlyImage = false;
      return new GestureDetector(
          onLongPress: () {
            _copyMessageDialog(context, message);
          },
          child: new Text(message));
    }


    // if its only an image message
    if(message == null && imageLink != null){


        isOnlyImage = true;
        return _getImage(imageLink, thumbnailLink, isCurrentUserMessage);


    }

    //its an image and text message
    if(message != null && imageLink != null){

        isOnlyImage = false;
        Widget img = _getImage(imageLink, thumbnailLink, isCurrentUserMessage);
        Widget txt = new GestureDetector(
            onLongPress: () {
              _copyMessageDialog(context, message);
            },
            child: new Text(message));

        return new Column(
          children: <Widget>[
            img, txt
          ],
        );



    }

    print("ERROR: message not defined. Probably a database issue");
    return new Container();

  }

  Widget _getImage(String imageUrl, String thumbnailUrl, bool myMessage) {
    final Radius radius = const Radius.circular(15.0);
    final Radius noRadius = const Radius.circular(0.0);



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
            child: new Material(
              color: Colors.black,
              borderRadius: new BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: myMessage ? radius : noRadius,
                  bottomRight: myMessage ? noRadius : radius),
              elevation: 2.0,
              child: new FadeInImage(
                placeholder: new AssetImage("images/loader.gif"),
                image: new NetworkImage(thumbnailUrl),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      );
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

  bool isOnlyImage;

  @override
  Widget build(BuildContext context) {

    // determine who the message is from, for displaying differences
    Map<String, dynamic> sender = widget.snapshot.value['sender'];
    bool isCurrentUserMessage = sender["id"] == widget.currentUser.userID;
    String name = widget.snapshot.value['sender']['name'];

    // function that figures out what this message is
    Widget messageContent = getMessageContent();


    //timestamp
    DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(
        widget.snapshot.value['timestamp']);
    Widget time = new Text(convertToTimeString(timestamp));




      return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: widget.animation, curve: Curves.easeOut),
        child: new MessageWrapper(
            isOnlyImage: isOnlyImage,
            myMessage: isCurrentUserMessage,
            child: messageContent,
            name: new Text(name),
            time: time),
      );

  }


}

class MessageWrapper extends StatelessWidget {
  const MessageWrapper(
      {@required this.child,
      @required this.myMessage,
      this.name,
      this.time,
        this.isOnlyImage
      });

  final Widget child;
  final bool myMessage;
  final Widget name;
  final Widget time;
  final bool isOnlyImage;
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
              padding: !this.isOnlyImage ? const EdgeInsets.all(10.0) : null,
              margin:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              constraints: new BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2),
              decoration: !this.isOnlyImage
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
