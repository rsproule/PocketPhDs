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
  Chat({@required this.currentUser, @required this.chatKey, this.canEdit = true});

  final String chatKey;
  final User currentUser;
  bool canEdit;

  @override
  _ChatState createState() => new _ChatState();
}

class _ChatState extends State<Chat> {
  Map<String, Widget> messageCache = new Map();
  Map<String, Uint8List> imageCache = new Map();
  Map<String, Uint8List> temp_thumbnailCache = new Map();
  Map<String, Uint8List> temp_imageCache = new Map();
  Map<String, Uint8List> thumbnailCache = new Map();

  bool _onScroll(ScrollUpdateNotification n) {
    // if the scroll is beyond a certain point trigger this

    // print(n.metrics.outOfRange);

    if (n.metrics.extentBefore > 30.0) {
      // this changes the focus away from the text field..
      // causes the keyboard to close
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    return true;
  }

  bool imageError = false;

  getImages(DataSnapshot snapshot) {
    String imageName = snapshot.value['image'];
    String thumbName = snapshot.value['thumbnail'];

    print(imageName);
    Map<String, String> sender = snapshot.value['sender'];
    String senderId = sender["id"];

    if (imageName == "saving.gif" && senderId != widget.currentUser.userID) {
      // DONT show the saving gif unless this is the current user
      return;
    }

    if (imageCache[snapshot.key] != null &&
        thumbnailCache[snapshot.key] != null) {
      // sanity check, don't re-download when its already here

      return;
    }

    if (imageName == "saving.gif" && temp_imageCache[snapshot.key] != null) {
      // saving thing already downloaded and its being requested again
      return;
    }

    if (thumbName == "saving.gif" && temp_thumbnailCache[snapshot.key] != null) {
      // saving thing already downloaded and its being requested again
      return;
    }

    if (imageError) {
      // dont keep trying if there is an error
      return;
    }

    if (imageName == null || thumbName == null) {
      //if either of these are null we should not be downloading
      return;
    }


    StorageReference imageRef = FirebaseStorage.instance.ref().child(imageName);
    StorageReference thumbRef = FirebaseStorage.instance.ref().child(thumbName);

    ///Image
    imageRef.getData(2500001).then((data) {
      if (this.mounted) {
        setState(() {
          if (imageName != "saving.gif") {
            imageCache[snapshot.key] = data;
          } else {
            temp_imageCache[snapshot.key] = data;
          }
        });
      }
    }).catchError((err) async {
      var bytes = await rootBundle.load("images/download_error.png");
      setState(() {
        if(this.mounted) {
          temp_imageCache[snapshot.key] = bytes.buffer.asUint8List();
          imageError = true;
        }
      });
    });

    /// Thumbnail
    thumbRef.getData(2500001).then((data) {
      if (this.mounted) {
        setState(() {
          if (thumbName != "saving.gif") {
            thumbnailCache[snapshot.key] = data;
          } else {
            temp_thumbnailCache[snapshot.key] = data;
          }
        });
      }
    }).catchError((err) async {
      print(err);
      var bytes = await rootBundle.load("images/download_error.png");
      if(this.mounted) {
        setState(() {
          temp_thumbnailCache[snapshot.key] = bytes.buffer.asUint8List();
          imageError = true;
        });
      }
    });
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
                    // Do NO loading.. we already have the correct message
                    if (messageCache.containsKey(snapshot.key)) {
                      return messageCache[snapshot.key];
                    }

                    // check if there even is an image we need to worry about
                    bool hasImage = snapshot.value['image'] != null;
                    if (!hasImage) {
                      ChatMessage m = new ChatMessage(
                          snapshot: snapshot,
                          animation: animation,
                          currentUser: widget.currentUser);
                      messageCache[snapshot.key] = m;
                      return m;
                    }

                    // this message has an image

                    // has it loaded the main images
                    if (thumbnailCache[snapshot.key] != null &&
                        imageCache[snapshot.key] != null) {
                      ChatMessage m = new ChatMessage(
                        snapshot: snapshot,
                        animation: animation,
                        currentUser: widget.currentUser,
                        image: imageCache[snapshot.key],
                        thumbnail: thumbnailCache[snapshot.key],
                      );
                      // add to cache  as this is final state of image msg
                      messageCache[snapshot.key] = m;
                      return m;
                    }




                    // it has not loaded the main images yet so keep checking
                    getImages(snapshot);

                    // if the loading message is
                    Map<String, String> sender = snapshot.value['sender'];
                    String senderId = sender["id"];
                    if(widget.currentUser.userID != senderId){
                      return new Container();
                    }

                    // has it got the temporary images atleast
                    if (temp_thumbnailCache[snapshot.key] != null &&
                        temp_imageCache[snapshot.key] != null) {
                      ChatMessage m = new ChatMessage(
                        snapshot: snapshot,
                        animation: animation,
                        currentUser: widget.currentUser,
                        image: temp_imageCache[snapshot.key],
                        thumbnail: temp_thumbnailCache[snapshot.key],
                      );
                      return m;
                    }

                    // nothing at all has loaded yet and it is an image file
                    return new ChatMessage(
                      snapshot: snapshot,
                      animation: animation,
                      currentUser: widget.currentUser,
                      image: null,
                      thumbnail: null,
                    );
                  })),
        ),
        new Divider(
          height: 0.0,
        ),
        widget.canEdit ? new MessageComposer(
          chatKey: widget.chatKey,
          currentUser: widget.currentUser,
        ) : new Container()
      ],
    );
  }
}
