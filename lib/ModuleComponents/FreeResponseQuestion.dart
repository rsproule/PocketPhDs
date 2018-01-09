import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/QuizPage.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';

class FreeResponseQuestion extends StatefulWidget {
  FreeResponseQuestion({@required this.question, @required this.currentUser});

  Question question;
  User currentUser;

  @override
  _FreeResponseQuestionState createState() => new _FreeResponseQuestionState();
}

class _FreeResponseQuestionState extends State<FreeResponseQuestion> {
  TextEditingController responseController = new TextEditingController();
  FocusNode _textFocusNode = new FocusNode();

  _save() {
    FocusScope.of(context).requestFocus(new FocusNode());

    widget.question.response.ref.set(responseController.text);
  }

  _editListener() {
    if(!widget.question.canEdit && _textFocusNode.hasFocus){
      FocusScope.of(context).requestFocus(new FocusNode());

      showDialog(
          context: context,
          child: new AlertDialog(
              title: new Text(
                  "You cannot edit this."),
              actions: [
                new PlatformButton(
                  child: new Text("Got it"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]));
      return;
    }


    if (widget.question.submitted && _textFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());

      showDialog(
          context: context,
          child: new AlertDialog(
              title: new Text(
                  "Quiz already submitted. You can no longer edit this."),
              actions: [
                new PlatformButton(
                  child: new Text("Got it"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]));
    }
  }

  StreamSubscription s;

  initState() {
    super.initState();

    _textFocusNode.addListener(_editListener);


    s = widget.question.response.ref.onValue.listen((e) {
      var val = e.snapshot.value;
      if (val.runtimeType == String) {
        setState(() {
          responseController.text = val;
        });
      }
    });
  }

  dispose() {
    s.cancel();
    _textFocusNode.removeListener(_editListener);
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String question = widget.question.question;
    if (!question.endsWith("?")) {
      question += "?";
    }

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

          new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Container(
              decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.black12)),
              child: new Container(
                padding: const EdgeInsets.all(10.0),
                alignment: new Alignment(-1.0, -1.0),
                child: new TextField(
                  controller: this.responseController,
                  focusNode: _textFocusNode,
                  onChanged: (v) {
                    setState(() {});
                  },
                  maxLines: null,
                  decoration: new InputDecoration(
                    hintText: "Enter response here.",
                    hideDivider: true,
                    counterText: responseController.text.length.toString(),
                  ),
                ),
              ),
            ),
          ),
          widget.question.canEdit
              ? new PlatformButton(
                  child: new Text("Save"),
                  onPressed: _save,
                )
              : new Container()
        ],
      ),
    );
  }
}
