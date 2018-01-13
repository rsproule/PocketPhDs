import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/Homepages/StudentHomePage.dart';
import 'package:pocketphds/User.dart';

class TutorHomePage extends StatefulWidget {
  TutorHomePage({this.currentUser});

  final User currentUser;
  @override
  _TutorHomePageState createState() => new _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> {
  String tipTitle;
  String tipBody;

  bool hasLoaded = false;

  initState(){
    super.initState();

    DatabaseReference tipRef = FirebaseDatabase.instance.reference().child("tipOfDay");
    tipRef.once().then((snap) {
      print("loaded");
      setState((){
        tipTitle = snap.value['title'];
        tipBody = snap.value['body'];
        hasLoaded = true;
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
              hasLoaded ? new TipOfTheDay(
                title: this.tipTitle,
                body: this.tipBody,
              ) : new Center(child: new CircularProgressIndicator(),),
              new Divider(),
              new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Text(
                    "Whatever else we want to put on the Tutor"
                        " home page: \n "
                        "ideas: \n "
                        "- some stats about the platform \n"
                        "- some stats about the students",
                    style: Theme.of(context).textTheme.title,
                  ))
            ]))
      ],
    );
  }
}
