import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/ChatComponents/Chat.dart';
import 'package:pocketphds/Drawer.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/chatUtils.dart';

class TutorChat extends StatefulWidget {
  TutorChat({this.currentUser});


  User currentUser;

  @override
  _TutorChatState createState() => new _TutorChatState();
}

class _TutorChatState extends State<TutorChat> {




  bool _student(DataSnapshot s){
    return s.value['type'] == 'student';
  }

  bool _parent(DataSnapshot s) {
    return s.value['type'] == 'parent';
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
                tabs: [new Tab(text: "Students"), new Tab(text: "Parents",)],
                labelColor: Theme.of(context).accentColor,
                indicatorColor: Theme.of(context).accentColor,
              ),
            ])),
            new SliverFillRemaining(
              child: new TabBarView(

                  children: [
                    new TutorChatList(filter: _student, currentUser: widget.currentUser,),
                    new TutorChatList(filter : _parent, currentUser: widget.currentUser,)

                  ]),
            )
          ],
        )
    );
  }
}


class TutorChatList extends StatelessWidget {

  TutorChatList({this.filter, @required this.currentUser});
  DatabaseReference chats = FirebaseDatabase.instance.reference().child("chats");
  var filter;
  User currentUser;

  openChat(DataSnapshot snap, BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context){
      return new Scaffold(
        appBar: new AppBar(title: new Text(snap.value['name']),),
        body: new Chat(chatKey: snap.key, currentUser: currentUser, canEdit: true,),
      );
    }));
  }


  @override
  Widget build(BuildContext context) {
    return new FirebaseAnimatedList(
          query: chats,
          sort: (a, b) {
            return b.value['timestamp'] - a.value['timestamp'];
          },
          itemBuilder: (_, snapshot, animation, index){
            DateTime timestamp = new DateTime.fromMillisecondsSinceEpoch(snapshot.value['timestamp']);
            bool isActive = snapshot.value['isActive'] != null ? snapshot.value['isActive'] : false;
            if(isActive && this.filter(snapshot)){
              return new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(snapshot.value["name"]),
                    subtitle: new Text(snapshot.value['lastMessage']),
                    trailing: new Text(convertToTimeString(
                        timestamp, abbreviated: true, timeOn: false)),
                    onTap: (){openChat(snapshot, _);},

                  ),
                  new Divider(height: 0.0,)
                ],
              );
            }else{
              return new Container();
            }
          },
        );
  }
}

