import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pocketphds/ForgotPassword.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';

class LoginDialog extends StatefulWidget {
  @override
  _LoginDialogState createState() => new _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static const platform = const MethodChannel('pocketphds/resetPass');

  TextEditingController _emailTextController = new TextEditingController();
  TextEditingController _passwordTextController = new TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool hasError = false;
  String errorMessage = "";

  _login() async {
    _auth
        .signInWithEmailAndPassword(
            email: _emailTextController.text,
            password: _passwordTextController.text)
        .then((user) async {
      DataSnapshot snap = await FirebaseDatabase.instance
          .reference()
          .child("users")
          .child(user.uid)
          .once();

      if (snap.value["type"] != "teacher") {
        // pop this full screen dialog with the user as payload
        Navigator.of(context).pop(user);
      } else {
        setState(() {
          this.hasError = true;
          this.errorMessage =
              "Mobile app not available for teacher accounts. Manage your classes online at Pocketphds.com.";
        });
      }
    }).catchError((error) {
      // print(error);
      setState(() {
        this.hasError = true;
        this.errorMessage = error.details;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text("Login to Pocket PhDs"),
          automaticallyImplyLeading: false,
        ),
        body: new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Card(
            child: new Container(
                padding: const EdgeInsets.all(10.0),
                child: new Form(
                    autovalidate: false,
                    child: new ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        new TextFormField(
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.email),
                            hintText: 'E-mail',
                            labelText: 'Enter your E-mail',
                          ),
                          controller: _emailTextController,
                        ),
                        new TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.lock),
                            hintText: 'Password',
                            labelText: 'Enter your password',
                          ),
                          controller: _passwordTextController,
                        ),
                        new Container(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: new PlatformButton(
                              onPressed: _login,
                              child: new Text(
                                "Login",
                                style: new TextStyle(color: Colors.white),
                              ),
                              color: Colors.blue),
                        ),
                        new Container(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: new PlatformButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (BuildContext build) {
                                  return new ForgotPassword();
                                }));
                              },
                              child: new Text(
                                  "Forgot Password or haven't set one?")),
                        ),
                        this.hasError
                            ? new Text(
                                this.errorMessage,
                                style: new TextStyle(color: Colors.red),
                              )
                            : new Container()
                      ],
                    ))),
          ),
        ));
  }
}
