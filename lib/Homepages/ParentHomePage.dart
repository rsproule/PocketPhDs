import 'package:flutter/material.dart';
import 'package:pocketphds/Homepages/StudentHomePage.dart';
import 'package:pocketphds/User.dart';

class ParentHomePage extends StatefulWidget {
  ParentHomePage({this.currentUser});

  User currentUser;

  @override
  _ParentHomePageState createState() => new _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
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
          new TipOfTheDay(
            title: "Get enough sleep to de-toxify your brain",
            body: "The advice to get enough sleep before an exam or important"
                " performance is age-old, but it is not often accompanied by "
                "a strong rationale of why this is important. When we sleep, our"
                " brain cells shrink a little, allowing toxins that accumulate in"
                " the brain to wash out. Explaining this helps us to put the proper"
                " value on getting a good night’s rest.",
          ),
          new Divider(),
          new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Text(
                "Whatever else we want to put on the parent"
                    " home page: \n "
                    "ideas: \n "
                    "- some stats about the platform \n"
                    "- some stats about learning in general \n"
                    "- info about parents role in students learning experience",
                style: Theme.of(context).textTheme.title,
              ))
        ]))
      ],
    );
  }
}
