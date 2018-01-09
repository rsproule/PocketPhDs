import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformButton extends StatelessWidget {
  PlatformButton(
      {@required this.child,
      @required this.onPressed,
      this.color,
      this.padding,
      this.minSize});

  VoidCallback onPressed;
  Widget child;
  Color color;
  EdgeInsets padding = const EdgeInsets.all(4.0);
  double minSize = 0.0;

  @override
  Widget build(BuildContext context) {

    Widget androidWidget = child.runtimeType == Icon
        ? new IconButton(
            icon: child,
            onPressed: onPressed,
            color: color,
          )
        : new MaterialButton(
            child: child,
            onPressed: this.onPressed,
            color: color,
            padding: padding,
          );

    return Theme.of(context).platform == TargetPlatform.iOS
        ? new CupertinoButton(
            padding: padding,
            child: child,
            onPressed: onPressed,
            color: color,
            minSize: minSize,
          )
        : androidWidget;
  }
}
