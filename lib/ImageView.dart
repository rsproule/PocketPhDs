import 'package:flutter/material.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';

class ImageView extends StatefulWidget {
  ImageView({this.image});

  final ImageProvider image;

  @override
  _ImageViewState createState() => new _ImageViewState();
}

class _ImageViewState extends State<ImageView>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;
  Offset lastPosition;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset =
        new Offset(size.width, size.height) * (1.0 - _scale);

    return new Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
      //dismiss = true;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = (details.focalPoint - _normalizedOffset * _scale);
      lastPosition = details.focalPoint;
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    setState(() {
      _offset = _clampOffset(lastPosition - _normalizedOffset * _scale);
    });

    if (magnitude > 600 && magnitude < 800) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      final double distance = (Offset.zero & context.size).shortestSide;
      _flingAnimation = new Tween<Offset>(
              begin: _offset, end: _clampOffset(_offset + direction * distance))
          .animate(_controller);
      _controller
        ..value = 0.0
        ..fling(velocity: magnitude / 1000.0);
    } else if (magnitude > 800) {
      Navigator.of(context).pop();
    }
  }

  void _handleLongPress(context) {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Save Image?"),
          actions: [
            new PlatformButton(
              child: new Text(
                "Cancel",
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new PlatformButton(
              child: new Text("Save"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
//      onLongPress: () {
//        _handleLongPress(context);
//      },
      child: new ClipRect(
        child: new Transform(
          transform: new Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: new FadeInImage(
              placeholder: new AssetImage("images/loader.gif"),
              image: widget.image),
        ),
      ),
    );
  }
}
