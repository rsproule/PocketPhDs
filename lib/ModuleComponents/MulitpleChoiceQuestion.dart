import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/QuizPage.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  MultipleChoiceQuestion(
      {@required this.question, @required this.currentUser});

  Question question;
  User currentUser;

  @override
  _MultipleChoiceQuestionState createState() =>
      new _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  String currentChoice;

  _changeChoice(String val) async {
    if(!widget.question.canEdit){
      showDialog(
          context: context,
          child: new AlertDialog(
              title: new Text(
                  "You cannot edit this."),
              actions: [new PlatformButton(
                child: new Text("Got it"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),]
          ));
      return;
    }

    if (!widget.question.submitted) {
      await widget.question.response.ref.set(val);

      setState(() {
        currentChoice = val;
      });
    } else {
      showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text(
                "Quiz already submitted. You can no longer edit this."),
            actions: [new PlatformButton(
              child: new Text("Got it"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),]
          ));
    }
  }

  StreamSubscription s;

  initState() {
    super.initState();

    s = widget.question.response.ref.onValue.listen((e) {
      var val = e.snapshot.value;
      setState(() {
            print(val);
            setState(() {
              currentChoice = val;
            });

      });
    });
  }

  dispose() {
    s.cancel();
    super.dispose();
  }

  _getOptions(List<Map<String, String>> opts){
    List<Widget> widgets = [];
    int i = 0;
    for(Map<String, String> option in opts){
      Widget w = new Column(
        children: <Widget>[
          new Divider(
            height: 0.0,
          ),
          new RadioListTile(
            value: option["option"],
            groupValue: currentChoice,
            onChanged: _changeChoice,
            title: new Text(option["option"]),
            activeColor: Colors.blue,
            selected: currentChoice == option["option"],
          ),
          new Divider(
            height: 0.0,
          )
        ],
      );
      widgets.add(w);
      i++;
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    String question = widget.question.question;
    if (!question.endsWith("?")) {
      question += "?";
    }


    List<Widget> options = _getOptions(widget.question.options);



    int i = 0;
    return new Container(
      margin: const EdgeInsets.only(bottom: 50.0, top: 15.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Question
          new Container(
              padding: const EdgeInsets.all(20.0),
              child:
                  new Text(question, style: Theme.of(context).textTheme.title)),
          //options
          new Column(
            children: options
          )
        ],
      ),
    );
  }
}
