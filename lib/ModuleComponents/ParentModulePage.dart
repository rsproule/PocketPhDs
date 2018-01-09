import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ModuleComponents/LessonsPage.dart';
import 'package:pocketphds/User.dart';

// here get the student object associated with the parent

class ParentModulePage extends StatefulWidget {
  ParentModulePage({@required this.currentUser});

  final User currentUser;

  @override
  _ParentModulePageState createState() => new _ParentModulePageState();
}

class _ParentModulePageState extends State<ParentModulePage> {
  Map<String, User> students = new Map();

  @override
  void initState() {
    super.initState();

    widget.currentUser.students.forEach((studentId, x) async {
      DatabaseReference ref =
          FirebaseDatabase.instance.reference().child("users").child(studentId);

      DataSnapshot snapshot = await ref.once();
      String name = snapshot.value['name'];
      UserType type = convertStringToUserType(snapshot.value['type']);
      String chatId = snapshot.value['chat'];
      String email = snapshot.value['email'];
      Map<String, dynamic> modules = snapshot.value['modules'];

      User s = new User(
          name: name,
          userID: studentId,
          type: type,
          chatId: chatId,
          email: email,
          modules: modules,
          firebase_user: null);

      setState(() {
        students[snapshot.key] = s;
      });
    });
  }

  _openModule(User user) {
    Navigator
        .of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text(user.name + "'s Modules"),
          ),
          body: new LessonsPage(
            currentUser: user,
            canEdit: false,
          ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return students.length > 0
        ? new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.all(20.0),
                  child: new Text(
                    "Your Students: ",
                    style: Theme.of(context).textTheme.title,
                  )),
              new Divider(height: 0.0,),
              new ListView(
                shrinkWrap: true,
                children: students.values.map((user) {
                  return new Column(
                    children: <Widget>[
                      new ListTile(
                        onTap: () {
                          _openModule(user);
                        },
                        title: new Text(user.name),
                        leading: new Icon(Icons.school),
                        subtitle: new Text(
                            user.modules.length.toString() + " Modules"),
                      ),
                      new Divider(
                        height: 0.0,
                      )
                    ],
                  );
                }).toList(),
              ),
            ],
          )
        : new Center(
            child: new CircularProgressIndicator(),
          );
  }
}
