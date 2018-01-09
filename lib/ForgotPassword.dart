import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';


class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailTextController = new TextEditingController();
  static const platform = const MethodChannel('rsproule.pocketphds/sendResetPasswordEmail');


  bool hasError = false;
  String errorMessage;

  _forgotPassword() async {
    String email = _emailTextController.text;
    /// TODO : make the platfrom channels for this

    try {
        var sentEmail = await platform.invokeMethod('sendResetPasswordEmail',
            <String, String> {
              'email' : email
            });
        // deals with when we return an int instead of bool
        bool sent = sentEmail.runtimeType == int ? (sentEmail == 1) : sentEmail;

      if(sent) {
        _scaffoldKey.currentState.showSnackBar(
            new SnackBar(
                content: new Text("Check the provided email to reset your password!")
            )
        );
        setState((){
          _emailTextController.clear();
          hasError = false;
          errorMessage = "";
        });
      }else {
        print("Not sent");
        setState(() {
          hasError = true;
          errorMessage = "This email account does not have a Pocket PhDs account.";
        });
      }
    } on PlatformException catch (e){
      setState((){
        this.hasError = true;
        this.errorMessage = e.details;
      });
    }




  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: new Text("Forgot Password"),),
      body: new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          child: new Container(
            child: new Form(
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.email),
                      hintText: 'you@domain.com',
                      labelText: 'Enter your E-mail',
                    ),
                    controller: _emailTextController,
                  ),
                  new Center(
                    child: new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: this.hasError ? new Text(this.errorMessage, style: new TextStyle(color: Colors.red),) : new Container(),
                    ),
                  ),

                  new Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    padding: const EdgeInsets.all(10.0),
                    child: new PlatformButton(
                      onPressed: _forgotPassword,
                      child: new Text("Send Reset Password Email", style: const TextStyle(color: Colors.white),),
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
