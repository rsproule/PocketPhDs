import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/ModuleComponents/Module.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/chatUtils.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage(
      {@required this.modulesMap,
      @required this.currentUser,
      @required this.logOut});

  final Map<String, Module> modulesMap;
  final User currentUser;
  final logOut;

  @override
  _StudentHomePageState createState() => new _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  Module currentModule;
  bool hasLoaded = false;
  String tipTitle;
  String tipBody;

  bool tipHasLoaded = false;

  @override
  void initState() {
    super.initState();
    if(widget.modulesMap.length < 1){
      setState((){
        hasLoaded = true;
      });
      return;
    }

    widget.modulesMap.forEach((k, m) {
      Module main;
      if (!(m.videoWatched && m.quizTaken)) {
        main = currentModule;
        if(currentModule != null){
          if(m.dueDate.isBefore(currentModule.dueDate)){
            main = m;
          }
        }else{
          main = m;
        }

        setState(() {
          currentModule = main;
          hasLoaded = true;
        });
      }
    });

    DatabaseReference tipRef =
        FirebaseDatabase.instance.reference().child("tipOfDay");
    tipRef.once().then((snap) {
      setState(() {
        tipTitle = snap.value['title'];
        tipBody = snap.value['body'];
        tipHasLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
      slivers: [
        new SliverAppBar(
          expandedHeight: 256.0,
//            floating: true,
          pinned: true,
          flexibleSpace: new FlexibleSpaceBar(
            title: const Text('Pocket PhDs'),
            background: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new Image.asset(
                  'images/nuerons.gif',
                  fit: BoxFit.cover,
                  height: 256.0,
                ),
                // This gradient ensures that the toolbar icons are distinct
                // against the background image.
                const DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: const LinearGradient(
                      begin: const Alignment(0.0, -1.0),
                      end: const Alignment(0.0, -0.4),
                      colors: const <Color>[
                        const Color(0x60000000),
                        const Color(0x00000000)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        new SliverList(
            delegate: new SliverChildListDelegate(<Widget>[
          new Container(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0),
            child: new Text(
              "Brain Tip of the Day: ",
              style: Theme.of(context).textTheme.headline,
            ),
          ),

          tipHasLoaded ? new TipOfTheDay(
            title: this.tipTitle,
            body: this.tipBody,
          ) : new Center(child: new CircularProgressIndicator(),),

          new Divider(),

          new Container(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0),
            child: new Text(
              "Current Brain Booster: ",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          hasLoaded && currentModule != null
              ? new ModuleCard(currentModule: this.currentModule)
              : new Container(
                  padding: const EdgeInsets.all(30.0),
                  child: new Text(
                    "No current Brain Booster. You are all caught up!",
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                  ),
                ),
          new Divider(),
//            new Text(
//              "Other Modules: ",
//              style: Theme.of(context).textTheme.headline,
//            ),
//            new Row(
//              children: widget.modulesMap.values.map((m) {
//                if (m != this.currentModule) {
//                  return new ModuleCard(currentModule: m);
//                } else
//                  return new Container();
//              }).toList(),
//            )
        ]))
      ],
    );
  }
}

class TipOfTheDay extends StatelessWidget {
  const TipOfTheDay({this.title, this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Material(
        borderRadius: new BorderRadius.circular(15.0),
        type: MaterialType.card,
        elevation: 2.0,
        child: new Container(
          padding: const EdgeInsets.all(10.0),
          color: Colors.blue.withOpacity(.27),
          child: new Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: new Column(
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Text(convertToTimeString(new DateTime.now(),
                        full: true, timeOn: false))
                  ],
                ),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: new Text(
                      title,
                      style: Theme.of(context).textTheme.title,
                    )),
                new Text(
                  "     " + body,
                  style: Theme.of(context).textTheme.body1,
                  textScaleFactor: 1.2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  const ModuleCard({@required this.currentModule});

  final Module currentModule;

  double _getCompletion() {
    int total = currentModule.questionCount + 1; // plus one for video
    int c = 0;
    if (currentModule.videoWatched) c++;
    if (currentModule.responses != null) {
      c += currentModule.responses.length;
    }
    return (c / total);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(20.0),
      child: currentModule != null
          ? _buildModule(context)
          : new Center(
              child: new CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildModule(BuildContext context) {
    double value = _getCompletion();
    Animation<Color> _valueColor =
        new AlwaysStoppedAnimation<Color>(Colors.blue);

    bool isDue = new DateTime.now().isAfter(currentModule.dueDate);

    Widget dueDateMessage = isDue
        ? new Text(
            "Late! Get this Done!",
            style: new TextStyle(color: Colors.red),
          )
        : new Text("Due: " +
            convertToTimeString(currentModule.dueDate,
                abbreviated: true, timeOn: false));

    return new Container(
      child: new Material(
        elevation: 2.5,
        type: MaterialType.card,
        borderRadius: new BorderRadius.circular(15.0),
        child: new Container(
          decoration: new BoxDecoration(
              border:
                  isDue ? new Border.all(color: Colors.red, width: 3.0) : null,
              borderRadius: new BorderRadius.circular(15.0)),
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Text(
                currentModule.name,
                style: Theme.of(context).textTheme.title,
              ),
              new Text(currentModule.description),
              new Center(
                heightFactor: 1.8,
                child: new PlatformButton(
                    color: Colors.blue,
                    padding: const EdgeInsets.all(15.0),
                    child: new Text(
                      "Open Brain Boosters",
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/modules");
                    }),
              ),
              new Row(children: <Widget>[
                new Text(((value * 100).toString().length > 4
                        ? (value * 100).toString().substring(0, 4)
                        : (value * 100).toString()) +
                    "% Complete"),
                new Expanded(child: new Container()),
                dueDateMessage
              ]),
              new Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: new LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.black12,
                  valueColor: _valueColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StudentView extends StatefulWidget {
  StudentView({this.logOut, this.currentUser});

  final User currentUser;
  final logOut;

  @override
  _StudentViewState createState() => new _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  //map containing all the students modules
  Map<String, Module> modules = new Map();

  //module listener to the students modules
  StreamSubscription moduleListener;

  bool loaded = false;

  //reference to the firebase database
  DatabaseReference fire = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();

    // will query all  the modules
    fire
        .child("users")
        .child(widget.currentUser.firebase_user.uid)
        .child("modules")
        .once()
        .then((modSnap) {
      if (modSnap.value != null) {
        loadInStudentModule(modSnap);
      }
    });
  }

  void loadInStudentModule(DataSnapshot snapshot) {
//    String classKey = snapshot.key;
//    Map<String, dynamic> modsMap = snapshot.value['modules'];
    setState((){
      loaded = true;
    });
    Map classesMap = snapshot.value;

    classesMap.forEach((k, v) {
      Map<String, dynamic> modsMap = classesMap[k]['modules'];



      List<Widget> tiles = [];
      modsMap.forEach((key, modSnap) {
        String name = modSnap['name'];
        String description = modSnap['description'];
        bool quizTaken = modSnap['quizTaken'];
        bool videoWatched = modSnap['videoWatched'];
        DateTime dueDate =
        new DateTime.fromMillisecondsSinceEpoch(modSnap['dueDate']);
        int questionCount = modSnap['questionCount'];
        var responses = modSnap['responses'];

        Module m = new Module(
            name: name,
            description: description,
            quizTaken: quizTaken,
            videoWatched: videoWatched,
            key: key,
            currentUserId: widget.currentUser.firebase_user.uid,
            dueDate: dueDate,
            questionCount: questionCount,
            responses: responses);

        this.setState(() {
          this.modules[key] = m;
        });
      });



    });


//    return m;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this.loaded) {
      return new StudentHomePage(
          modulesMap: modules,
          currentUser: widget.currentUser,
          logOut: widget.logOut);
    } else {
      return new Center(child: new CircularProgressIndicator());
    }

  }
}
