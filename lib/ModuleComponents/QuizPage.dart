import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/QuestionWrapper.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';

class QuizPage extends StatefulWidget {
  QuizPage(
      {@required this.user,
      @required this.moduleKey,
      @required this.canEdit,
      @required this.moduleName,
      @required this.submitted});

  final User user;
  final String moduleKey;
  bool canEdit;
  final String moduleName;
  bool submitted;

  @override
  _QuizPageState createState() => new _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  StreamSubscription questionStream;
  Map<String, Question> questionsMap = new Map();

  _submit() {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Are you sure you are ready to submit?"),
          content: new Text("You will not be able to edit this quiz after you submit."),
          actions: [
            new PlatformButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            new PlatformButton(
                child: new Text("Submit"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                })
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    Query questionsQuery = FirebaseDatabase.instance
        .reference()
        .child("modules")
        .child(widget.moduleKey)
        .child("quiz")
        .child("questions")
        .orderByKey();

    questionStream = questionsQuery.onValue.listen((e) async {
      DataSnapshot questionSnap = e.snapshot;

      List questions = questionSnap.value;

      int questionKey = 0;
      for (var DBQ in questions) {
        print(DBQ);

        /// get the users responses for each of these
        DatabaseReference responseReference = FirebaseDatabase.instance
            .reference()
            .child("users")
            .child(widget.user.userID)
            .child("modules")
            .child(widget.moduleKey)
            .child("responses")
            .child(questionKey.toString());

        DataSnapshot responseSnap = await responseReference.once();

        Response r =
            new Response(ref: responseReference, value: responseSnap.value);

        String questionText = DBQ['question'];
        QuestionType type = Question.setType(int.parse(DBQ['type']));

        /// Logic that gets the options or no options if freee respomse
        Question q;
        if (type != QuestionType.freeResponse) {
          // in form "option" : "The option"
          List<Map<String, String>> options = DBQ['options'];

          q = new Question(
              question: questionText,
              type: type,
              response: r,
              options: options,
              canEdit: widget.canEdit,
              submitted: widget.submitted);
        } else {
          // there are no options
          q = new Question(
              question: questionText,
              response: r,
              type: type,
              canEdit: widget.canEdit,
              submitted: widget.submitted);
        }

        /// update the UI
        setState(() {
          this.questionsMap[questionKey.toString()] = q;
        });
        questionKey++;
      }
    });
  }

  void dispose() {
    questionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.moduleName + " Quiz"),
      ),
      body: this.questionsMap.keys.length > 0
          ? new ListView(
              children: <Widget>[
                new Column(
                    children: questionsMap.values.map((Question q) {
                  return new QuestionWrapper(
                    question: q,
                    currentUser: widget.user,
                  );
                }).toList()),
                widget.canEdit && !widget.submitted
                    ? new Container(
                        margin: const EdgeInsets.symmetric(horizontal: 50.0),
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: new PlatformButton(
                          child: new Text("Submit"),
                          onPressed: _submit,
                          color: Colors.blue,
                        ),
                      )
                    : new Container()
              ],
            )
          : new Center(
              child: new CircularProgressIndicator(),
            ),
    );
  }
}

class Response {
  Response({this.value, @required this.ref});

  var value; // can be a string, int, or list
  final DatabaseReference ref;
}

//bool assertType(QuestionType type, value) {
//  switch (type) {
//    case QuestionType.multipleChoice:
//      return (value.runtimeType == int);
//    case QuestionType.freeResponse:
//      return (value.runtimeType == String);
//    case QuestionType.select:
//      return (value.runtimeType == List);
//    case QuestionType.notDone:
//      return true;
//    default:
//      return false;
//  }
//}

class Question {
  Question(
      {@required this.question,
      @required this.canEdit,
      @required this.submitted,
      this.type,
      @required this.response,
      this.options});

  final String question;
  final QuestionType type;
  final Response response;
  final List<Map<String, String>> options;
  final bool canEdit;
  final bool submitted;

  static QuestionType setType(int i) {
    List<QuestionType> t = [
      QuestionType.multipleChoice,
      QuestionType.select,
      QuestionType.freeResponse,
    ];

    return t[i];
  }
}

enum QuestionType { multipleChoice, select, freeResponse }
