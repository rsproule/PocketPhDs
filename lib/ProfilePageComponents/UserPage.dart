import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketphds/ImageView.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';

class UserPage extends StatefulWidget {
  UserPage({this.currentUser});

  final User currentUser;

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Header(
          user: widget.currentUser,
        ),
        new Divider(),
      ],
    );
  }
}

class Header extends StatefulWidget {
  Header({@required this.user});

  final User user;

  @override
  _HeaderState createState() => new _HeaderState();
}

class _HeaderState extends State<Header> {
  File newImage;
  String profileImageUrl;

  _changePhoto() async {
    File image = await _getImage();

    if (image != null) {
      setState(() {
        newImage = image;
      });
      //upload to firebase
      int random = new Random().nextInt(1000000);
      String filename = "prof_" + random.toString() + ".jpg";

      StorageReference ref =
          FirebaseStorage.instance.ref().child("profileImages/$filename");

      StorageUploadTask uploadTask = ref.put(image);

      Uri imgUrl = (await uploadTask.future).downloadUrl;

      DatabaseReference dbRef = FirebaseDatabase.instance
          .reference()
          .child("users")
          .child(widget.user.userID)
          .child("profileUrl");

      dbRef.set(imgUrl.toString());
    }
  }

  _getImage() async {
    // show the buttons to make sure the focus goes away from the text field
    try {
      File img = await ImagePicker.pickImage();

      if (img != null) {
        return img;
      }
    } catch (e) {
//      // print("No image selected");
    }
  }

  StreamSubscription s;

  initState() {
    super.initState();

    s = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.user.userID)
        .child("profileUrl")
        .onValue
        .listen((e) {
      DataSnapshot s = e.snapshot;
      setState(() {
        profileImageUrl = s.value;
      });
    });
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



  @override
  Widget build(BuildContext context) {
    ImageProvider photo = profileImageUrl != null
        ? new NetworkImage(profileImageUrl)
        : this.newImage != null
            ? new Image.file(newImage)
            : new AssetImage("images/loader.gif");

    TextStyle titleTheme = Theme.of(context).textTheme.title;

    Widget _name = new Text(
      widget.user.name,
      style: titleTheme,
    );

    return new Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: new Column(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new GestureDetector(
                child: new Hero(
                  tag: "ProfilePicture",
                  child: new CircleAvatar(
                    radius: 50.0,
                    backgroundImage: photo,
                    child: this.newImage == null && this.profileImageUrl == null
                        ? new Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40.0,
                          )
                        : new Container(),
                  ),
                ),
                onTap: () {
                  photo.runtimeType != Container
                      ? showPhoto(context, photo, "ProfilePicture")
                      : null;
                },
              ),
              new Container(
                  padding: const EdgeInsets.all(5.0),
                  child: new FlatButton(
                      child: new Text("Change Photo"),
                      onPressed: _changePhoto)),
            ],
          ),
          new Divider(
            color: Colors.transparent,
          ),
          _name,
          new Text(widget.user.firebase_user.email),
        ],
      ),
    );
  }
}
