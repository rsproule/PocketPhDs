import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketphds/PlatformSpecificWidgets.dart';
import 'package:pocketphds/User.dart';
import 'package:pocketphds/utils/chatUtils.dart';

class MessageComposer extends StatefulWidget {
  MessageComposer({@required this.currentUser, @required this.chatKey});

  User currentUser;
  String chatKey;

  @override
  _MessageComposerState createState() => new _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  TextEditingController _messageText = new TextEditingController();
  FocusNode _textInputNode = new FocusNode();

  List<File> _imageFiles = [];
  List<File> _files = [];

  bool showMultimediaButtons = true;
  String errorMsg = "Unknown Error";
  bool error = false;
  bool sending = false;

  _getImage() async {
    // show the buttons to make sure the focus goes away from the text field
    _showButtons();
    try {
      var img = await ImagePicker.pickImage();

      if (img != null) {
        setState(() {
          _imageFiles.add(img);
        });
      }
    } catch (e) {
//      print("No image selected");
    }
  }

  _handleChange(String newVal) {
    if (newVal.length > 10 || _imageFiles.length > 0) {
      setState(() {
        showMultimediaButtons = false;
      });
    } else {
      setState(() {
        showMultimediaButtons = true;
      });
    }
  }

  _showButtons() {
    setState(() {
      showMultimediaButtons = true;
    });
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  _inputListener() {
    if (_textInputNode.hasFocus) {
      String newVal = _messageText.text;
      if (newVal.length > 10 || _imageFiles.length > 0) {
        setState(() {
          showMultimediaButtons = false;
        });
      } else {
        setState(() {
          showMultimediaButtons = true;
        });
      }
    }
  }

  _removeImage(int i) {
    setState(() {
      _imageFiles.removeAt(i);
    });
  }

  bool _canSend() {
    return _messageText.text != "" ||
        _imageFiles.length > 0 ||
        _files.length > 0;
  }

  _sendMessage() {
    String message = _messageText.text;

    // make sure its not completely blank
    if (!_canSend()) return;
    sending = true;
    String msgStash = message;
    List<File> imgStash = new List.from(_imageFiles);
    List<File> fileStash = new List.from(_files);

    // clear all the
    setState(() {
      _messageText.clear();
      _imageFiles.clear();
      _files.clear();
    });

    sendMessage(
        message: msgStash,
        imageFiles: imgStash,
        files: fileStash,
        user: widget.currentUser,
        chatKey: widget.chatKey).then((success) {
      if (success) {
        setState((){
          sending = false;
          msgStash = null;
          imgStash.clear();
          fileStash.clear();
          error = false;
        });
      } else {
        setState(() {
          sending = false;
          _messageText.text = msgStash;
          _imageFiles = imgStash;
          _files = fileStash;
          error = true;
          errorMsg = "Message Failed to Send. Must be under 2.5 Mb.";
        });
      }
    }).catchError((err) {
      setState(() {
        sending = false;
        _messageText.text = msgStash;
        _imageFiles = imgStash;
        _files = fileStash;
        error = true;
        errorMsg = "Message Failed to Send. Must be under 2.5 Mb.";
      });
    });
  }

  @override
  void initState() {
    _textInputNode.addListener(_inputListener);
  }

  @override
  void dispose() {
    _textInputNode.removeListener(_inputListener);
    _textInputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          showMultimediaButtons
              ? new PlatformButton(
                  child: new Icon(Icons.camera_alt),
                  onPressed: _getImage,
                )
              : new Container(),
          showMultimediaButtons
              ? new PlatformButton(
                  child: new Icon(Icons.attach_file),
                  onPressed: null,
                )
              : new Container(),
          !showMultimediaButtons
              ? new PlatformButton(
                  child: new Icon(Icons.chevron_right), onPressed: _showButtons)
              : new Container(),
          new Expanded(
            child: new Container(
              margin: const EdgeInsets.all(5.0),
              padding:
                  const EdgeInsets.only(left: 15.0, bottom: 4.0, right: 15.0),
              decoration: new BoxDecoration(
                border: new Border.all(
                  width: 1.0,
                  color: error ? Colors.red : Colors.black12,
                ),
                borderRadius: new BorderRadius.circular(
                  15.0,
                ),
              ),
              child: new Column(
                children: <Widget>[
                  new ImagesToSend(
                    images: _imageFiles,
                    removeImage: _removeImage,
                  ),
                  _imageFiles.length > 0
                      ? new Divider(
                          height: 0.0,
                        )
                      : new Container(),
                  new TextField(
                    style: new TextStyle(fontSize: 20.0, color: Colors.black),
                    controller: _messageText,
                    onChanged: _handleChange,
                    focusNode: _textInputNode,
                    maxLines: showMultimediaButtons ? 1 : null,
                    keyboardType: TextInputType.multiline,
                    decoration: new InputDecoration(
                      hideDivider: true,
                      hintText: "Send Message",
                    ),
                  ),
                  error
                      ? new Divider(
                          height: 0.0,
                        )
                      : new Container(),
                  error
                      ? new Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.red),
                        )
                      : new Container()
                ],
              ),
            ),
          ),
          sending
              ? new Container(
              margin: const EdgeInsets.all(10.0),
              child: new CircularProgressIndicator())
              : new PlatformButton(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new Text("Send")
                      : new Icon(Icons.send),
                  onPressed: _canSend() ? _sendMessage : null,
                )
        ],
      ),
    );
  }
}

class ImagesToSend extends StatelessWidget {
  ImagesToSend({this.images, this.removeImage});

  final List<File> images;
  var removeImage;

  @override
  Widget build(BuildContext context) {
    if (images.length < 1) {
      return new Container();
    }
    int i = 0;
    return new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Column(
        children: images.map((file) {
          Widget im = new SingleImage(
              image: new Image.file(file), remove: removeImage, index: i);
          i++;
          return im;
        }).toList(),
      ),
    );
  }
}

class SingleImage extends StatelessWidget {
  SingleImage({this.image, this.remove, this.index});

  final Image image;
  var remove;
  final int index;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Stack(
        children: <Widget>[
          image,
          new Container(
            margin: const EdgeInsets.all(4.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              border: new Border.all(
                width: 1.0,
                color: Colors.black12,
              ),
            ),
            child: new IconButton(
                icon: new Icon(Icons.delete_forever, color: Colors.white),
                onPressed: () {
                  remove(this.index);
                }),
          )
        ],
      ),
    );
  }
}
