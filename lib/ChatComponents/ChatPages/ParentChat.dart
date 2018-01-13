import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ChatComponents/Chat.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/ModuleComponents/LessonsPage.dart';
import 'package:pocketphds/User.dart';

class ParentChat extends StatefulWidget {
  ParentChat({this.currentUser});

  User currentUser;

  @override
  _ParentChatState createState() => new _ParentChatState();
}

class _ParentChatState extends State<ParentChat> {
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

  _openChat(User student) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(student.name + "'s Chat"),
        ),
         body: new Chat(
        currentUser: student,
        chatKey: student.chatId,
        canEdit: false,
      ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,

        child: new CustomScrollView(
          physics: new NeverScrollableScrollPhysics(),
          slivers: [
            new SliverList(delegate: new SliverChildListDelegate([
              new TabBar(
                  tabs: [new Tab(text: "Students"), new Tab(text: "Brain Coach",)],
                labelColor: Theme.of(context).accentColor,
                indicatorColor: Theme.of(context).accentColor,
              ),
            ])),
            new SliverFillRemaining(
              child: new TabBarView(

                  children: [
                new ListView(
                  primary: true,
                  children: students.values.map((u) {
                    return new Column(
                      children: <Widget>[
                        new ListTile(
                          title: new Text(u.name + "'s Chat with Brain Coach"),
                          leading: new Icon(Icons.chat),
                          onTap: () {
                            _openChat(u);
                          },
                          subtitle: new Text(
                              "Mirror only. You cannot send messages."),
                        ),
                        new Divider(
                          height: 0.0,
                        )
                      ],
                    );
                  }).toList(),
                ),
                new Chat(
                  currentUser: widget.currentUser,
                  chatKey: widget.currentUser.chatId,
                )
              ]),
            )
          ],
        )
    );
  }
}
