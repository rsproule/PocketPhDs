import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/QuizPage.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';

class SelectQuestion extends StatefulWidget {
  SelectQuestion({@required this.question, @required this.currentUser});

  Question question;
  User currentUser;

  @override
  _SelectQuestionState createState() => new _SelectQuestionState();
}

class _SelectQuestionState extends State<SelectQuestion> {
  Map<String, bool> selected = new Map();

  _onChange(String option, bool isSelected){

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

    if(!widget.question.submitted){
      //update database
      widget.question.response.ref.child(option).set(isSelected);
      //update UI
      setState((){
        selected[option] = isSelected;
      });
    }else{
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

  initState(){
    super.initState();
    setState((){
      Map<String, bool> selected = new Map();
      widget.question.options.forEach((opt){
        String option = opt["option"];
        selected[option] = false;
      });

      this.selected = selected;
    });

    s = widget.question.response.ref.onValue.listen((e) {
     var val = e.snapshot.value;
      // print(val);
      val.forEach((k, v){
        setState((){
          selected[k] = v;
        });
      });




    });
  }

  dispose(){
    s.cancel();
    super.dispose();
  }

  _getOptions(List<Map<String, String>> opts){
    List<Widget> widgets = [];
    int i = 0;
    for(Map<String, String> option in opts){
      bool val = this.selected[option['option']] != null ? this.selected[option['option']] : false;

      Widget w = new Column(
        children: <Widget>[
          new Divider(
            height: 0.0,
          ),
          new CheckboxListTile(
            title: new Text(option["option"]),
            activeColor: Colors.blue,
            selected: val,
            value: val,
            onChanged: (isSelected){

              _onChange(option["option"], isSelected);

            },
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
            children: options,
          )
        ],
      ),
    );
  }
}
