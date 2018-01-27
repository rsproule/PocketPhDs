import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/ModulePage.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/chatUtils.dart';
import 'package:pocketphds/utils/globals.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class LessonsPage extends StatefulWidget {
  LessonsPage({this.currentUser, this.canEdit = true});

  final User currentUser;
  bool canEdit;

  @override
  _LessonsPageState createState() => new _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  Map<String, Widget> _widgetCache = new Map();

  @override
  Widget build(BuildContext context) {
    DatabaseReference modules = FirebaseDatabase.instance
        .reference()
        .child("users")
        .child(widget.currentUser.userID)
        .child("modules");

    return new FirebaseAnimatedList(
        primary: true,
        query: modules,
        sort: (DataSnapshot a, DataSnapshot b){
          return a.value['dueDate'] - b.value['dueDate'];
        },
        itemBuilder: (_, DataSnapshot snapshot, Animation<double> anim, i) {
          String classKey = snapshot.key;
          Map<String, dynamic> modsMap = snapshot.value['modules'];
          String className = snapshot.value['className'];

          List<Widget> tiles = [];
          modsMap.forEach((key, snap){


              bool videoWatched = snap['videoWatched'];
              bool quizTaken = snap['quizTaken'];
              String name = snap['name'];
              String title = snap['title'];
              String description = snap['description'];
              DateTime dueDate =
                  new DateTime.fromMillisecondsSinceEpoch(snap['dueDate']);
              bool isUnlocked =
                  dueDate.difference(new DateTime.now()) < new Duration(days: 7);

              String moduleKey = key;

              if (!isUnlocked) {
                tiles.add(buildLockedTile(dueDate.subtract(new Duration(days: 7))));
              }else {
                tiles.add(buildUnlockedTile(
                    user: widget.currentUser,
                    videoWatched: videoWatched,
                    quizTaken: quizTaken,
                    description: description,
                    name: name,
                    title: title,
                    context: context,
                    moduleKey: moduleKey,
                    dueDate: dueDate,
                    canEdit: widget.canEdit,
                    classKey : classKey,
                    className : className
                ));
              }
          });

          return new Column(
            children: tiles,
          );
        });
  }
}

Widget buildLockedTile(DateTime unlockDate) {
  return new Column(
    children: <Widget>[
      new ActiveLine(
        isUnlocked: false,
      ),
      new Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: new Card(
          child: new ListTile(
            leading: new Icon(Icons.lock),
            title: new Text("Module is not unlocked yet."),
            subtitle: new Text("Unlocks: " +
                convertToTimeString(unlockDate, abbreviated: true)),
          ),
        ),
      ),
    ],
  );
}

Widget buildUnlockedTile(
    {BuildContext context,
    String name,
    String title,
    String description,
    String moduleKey,
    bool videoWatched,
    bool quizTaken,
    User user,
    DateTime dueDate,
    bool canEdit,
    String classKey,
    String className}) {

  bool isOverDue = new DateTime.now().isAfter(dueDate);
  bool isComplete = quizTaken && videoWatched;

  return new Column(
    children: <Widget>[
      new ActiveLine(
        isUnlocked: true,
      ),
      new Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: new Card(
          child: new Container(
            decoration:  isOverDue && !isComplete ? new BoxDecoration(
                border: new Border.all(color: Colors.red, width: 2.25)
            ) : null,
            child: new ListTile(
              leading: isComplete ?  new Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40.0,
              ) : null,
              title: new Text(name, style: new TextStyle(color: Colors.blue),),
              subtitle: new Text(title + " (Class: $className)"),
              trailing: new Text(
                "Due: \n" +
                    convertToTimeString(dueDate,
                        timeOn: false, abbreviated: true),
                maxLines: 3,
                style: new TextStyle(color: isOverDue && !isComplete ? Colors.red : null),
              ),

              onTap: () {
                Navigator
                    .of(context)
                    .push(new MaterialPageRoute(builder: (BuildContext build) {
                  return new ModulePage(
                      moduleKey: moduleKey,
                      name: title,
                      description: description,
                      videoWatched: videoWatched,
                      quizTaken: quizTaken,
                      currentUser: user,
                      canEdit : canEdit,
                      classKey: classKey,
                  );
                }));
              },
            ),
          ),
        ),
      ),
    ],
  );
}

class ActiveLine extends StatefulWidget {
  ActiveLine({this.isUnlocked});

  final bool isUnlocked;

  @override
  _ActiveLineState createState() => new _ActiveLineState();
}

class _ActiveLineState extends State<ActiveLine> {
  Widget unlocked = new Icon(
    Icons.lock_open,
    color: Colors.blue,
  );
  Widget locked = new Icon(
    Icons.lock,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          width: 2.0,
          color: widget.isUnlocked ? Colors.blue : Colors.grey,
          height: 25.0,
        ),
        widget.isUnlocked ? unlocked : locked,
        new Container(
          width: 2.0,
          color: widget.isUnlocked ? Colors.blue : Colors.grey,
          height: 25.0,
        ),
      ],
    );
  }
}
