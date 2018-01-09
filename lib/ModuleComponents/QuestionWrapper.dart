import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/FreeResponseQuestion.dart';
import 'package:pocketphds/ModuleComponents/MulitpleChoiceQuestion.dart';
import 'package:pocketphds/ModuleComponents/QuizPage.dart';
import 'package:pocketphds/ModuleComponents/SelectQuestion.dart';
import 'package:pocketphds/User.dart';

class QuestionWrapper extends StatefulWidget {
  QuestionWrapper({@required this.question, @required this.currentUser});

  Question question;
  User currentUser;

  @override
  _QuestionWrapperState createState() => new _QuestionWrapperState();
}

class _QuestionWrapperState extends State<QuestionWrapper> {
  @override
  Widget build(BuildContext context) {
    Map<QuestionType, Widget> questionType = {
      QuestionType.multipleChoice: new MultipleChoiceQuestion(
        question: widget.question,
        currentUser: widget.currentUser,
      ),
      QuestionType.select: new SelectQuestion(
        question: widget.question,
        currentUser: widget.currentUser,
      ),
      QuestionType.freeResponse: new FreeResponseQuestion(
        question: widget.question,
        currentUser: widget.currentUser,
      )
    };

    return questionType[widget.question.type];
  }
}
