import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:pocketphds/ModuleComponents/LessonsPage.dart';
import 'package:pocketphds/ModuleComponents/QuizPage.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/globals.dart';
import 'package:video_launcher/video_launcher.dart';

class ModulePage extends StatefulWidget {
  ModulePage(
      {@required this.name,
      @required this.moduleKey,
      @required this.videoWatched,
      @required this.quizTaken,
      @required this.currentUser,
      @required this.description,
      @required this.canEdit});

  final String name;
  final String moduleKey;
  bool videoWatched;
  bool quizTaken;
  User currentUser;
  final String description;
  bool canEdit;

  @override
  _ModulePageState createState() => new _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  // bool that tells whether the video has been watched yet, default false
  bool videoWatched = false;

  // same forn the quiz, default false
  bool quizTaken = false;

  //url used in the video view launch
  String videoUrl;

  // url used in the webview launch
  String quizUrl;

  //variable that decides to display the buttons
  bool loaded = false;

  // Instance of WebView plugin
  final FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

  Future<Null> _launchVideo(String url) async {



    if (await canLaunchVideo(url)) {
      await launchVideo(url);

      // report back that this guy has completed watching the video
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child("users")
          .child(widget.currentUser.userID)
          .child("modules")
          .child(widget.moduleKey);
      await ref.child("videoWatched").set(true);
    } else {
      throw 'Could not launch $url';
    }

    setState(() {
      if(widget.canEdit) {
        this.videoWatched = true;
      }
    });
  }

  _launchQuiz() async {
    bool finished =
        await Navigator.of(context).push(new MaterialPageRoute<bool>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return new QuizPage(
                user: widget.currentUser,
                moduleKey: widget.moduleKey,
                canEdit: widget.canEdit,
                moduleName: widget.name,
                submitted : this.quizTaken
              );
            }));

    if (finished == null) return;

    if (finished) {
      // alert quiz has been taken.. for now
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child("users")
          .child(widget.currentUser.userID)
          .child("modules")
          .child(widget.moduleKey);

      // mark both quiz and module as complete
      await ref.child("quizTaken").set(true);
      setState(() {
        quizTaken = true;
      });
    }
//
  }

  _getModuleInfo(String moduleKey) async {
    //check the bools
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.currentUser.userID)
        .child("modules")
        .child(widget.moduleKey);

    DataSnapshot userModuleSnap = await userRef.once();

    DataSnapshot module = await FirebaseDatabase.instance
        .reference()
        .child("modules")
        .child(widget.moduleKey)
        .once();

    bool vidWatched = userModuleSnap.value['videoWatched'];
    bool quizTaken = userModuleSnap.value['quizTaken'];

    setState(() {
      this.videoWatched = vidWatched;
      this.quizTaken = quizTaken;
      this.videoUrl = module.value['video'];
      loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _getModuleInfo(widget.moduleKey);
  }

  void error(BuildContext context) {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("You Must watch the video before taking the quiz!"),
          actions: [
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("OK"))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.name),
        ),
        body: loaded
            ? new ListView(
                children: <Widget>[
                  new Container(
                    child: new Center(
                      child: new Text(
                        widget.description,
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ),
                    padding: const EdgeInsets.all(25.0),
                  ),
                  new Divider(),

                  // The Video
                  new Container(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: new Card(
                      child: new ListTile(
                        title: new Text("Watch the Video"),
                        leading: new Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                        ),
                        trailing: this.videoWatched
                            ? new Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : new Icon(Icons.check_box_outline_blank),
                        onTap: () {
                          _launchVideo(videoUrl);
                        },
                      ),
                    ),
                  ),

                  //Connection from video to quiz
                  new ActiveLine(
                    isUnlocked: this.videoWatched,
                  ),

                  // Quiz
                  new Container(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: new Card(
                      child: new ListTile(
                        title: new Text("Take the Quiz"),
                        leading: new Icon(
                          Icons.assignment,
                          color: Colors.black,
                        ),
                        trailing: this.quizTaken
                            ? new Icon(
                                Icons.check_box,
                                color: Colors.green,
                              )
                            : new Icon(Icons.check_box_outline_blank),
                        onTap: videoWatched || !widget.canEdit
                            ? () {
                                _launchQuiz();
                              }
                            : () {
                                error(context);
                              },
                      ),
                    ),
                  ),
                  new ActiveLine(
                    isUnlocked: this.quizTaken,
                  ),

                  new Container(
                    child: new Icon(
                      Icons.check_circle,
                      color: quizTaken ? Colors.green : Colors.grey,
                      size: 80.0,
                    ),
                  )
                ],
              )
            : new Center(child: new CircularProgressIndicator()));
  }
}
