import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'main.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({@required this.logOut, this.isTutor = false});

  final logOut;
  final bool isTutor;

  @override
  _DrawerState createState() => new _DrawerState();
}

class _DrawerState extends State<AppDrawer> {
  _logoutDialog() {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Are you sure you want to log out?"),
          actions: [
            new PlatformButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("Cancel")),
            new PlatformButton(
                onPressed: () {
                  widget.logOut().then((logout) {
                    if (logout) {
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    }
                  });
                },
                child: new Text(
                  "Log Out",
                  style: new TextStyle(color: Colors.red),
                ))
          ],
        ));
  }

  _showAbout() {
    showAboutDialog(
        context: context,
        applicationName: "Pocket PhDs",
        applicationVersion: "v1.0.3",
        applicationIcon:new Image.asset("images/PPHD_clear_back.PNG", width: 54.0,),

        applicationLegalese: "Developed by Ryan Sproule");
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new Column(
        children: <Widget>[
          new DrawerHeader(
            child:
                new Image(image: new AssetImage("images/PPHD_clear_back.PNG")),
          ),

          // Top stuff
          new Expanded(
              child: new Column(
            children: <Widget>[
              new DrawerItem(title: "Home", icon: Icons.home, route: "/"),
              new DrawerItem(
                title: "Chat with Brain Coach",
                icon: Icons.chat,
                route: "/chat",
              ),
              !widget.isTutor
                  ? new DrawerItem(
                      title: "Brain Boosters",
                      icon: Icons.lightbulb_outline,
                      route: '/modules',
                    )
                  : new Container(),
              new DrawerItem(
                  title: "View Profile", icon: Icons.person, route: "/profile"),
              new Divider(
                height: 0.0,
              )
            ],
          )),

          // Bottom Stuff
          new Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new BottomButtons(
                      text: " Log Out",
                      color: Colors.red,
                      icon: Icons.exit_to_app,
                      onClick: _logoutDialog,
                    ),
                    new Expanded(
                      child: new BottomButtons(
                        text: " About",
                        color: Theme.of(context).backgroundColor,
                        icon: Icons.info_outline,
                        onClick: _showAbout,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({this.title, this.route, this.icon});

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Divider(
          height: 0.0,
        ),
        new ListTile(
          leading: new Icon(icon),
          title: new Text(title),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(route);
          },
        ),
      ],
    );
  }
}

class BottomButtons extends StatelessWidget {
  const BottomButtons({this.text, this.icon, this.onClick, this.color});

  final String text;
  final IconData icon;
  final onClick;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(10.0),
      child: new PlatformButton(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: new Row(
            children: <Widget>[
              new Icon(
                icon,
                color: Colors.black54,
              ),
              new Text(
                text,
                style: const TextStyle(color: Colors.black54),
              )
            ],
          ),
          color: color,
          onPressed: onClick),
    );
  }
}
