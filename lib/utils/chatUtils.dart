import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pocketphds/User.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // new

///sendMessage:
/// this function is responsible for sending all messages
///
/// case 1
/// if the message has no image it simply adds a message to the db
/// and updates the meta data for the chat
///
/// case 2
///
/// if there is an image or images. Each image is uploaded to the storage bucket
/// then the corresponding URL is placed in the database. This also triggers a
/// cloud function that will create a thumbnail of the image and then write that
/// to the database
///
/// returns : true on success. false on failure

Future<bool> sendMessage(
    {String message, User user, String chatKey, List<File> imageFiles}) async {
  final analytics = new FirebaseAnalytics(); // new
  analytics.logEvent(name: "sendMessage");
  DatabaseReference root = FirebaseDatabase.instance.reference();

  DatabaseReference messages = root.child('messages').child(chatKey);
  DatabaseReference chat = root.child("chats").child(chatKey);

  var timestamp = new DateTime.now().millisecondsSinceEpoch;

  /// CASE 1:
  // There was no image, only a text message
  if (imageFiles.length < 1) {
    // check to make sure there actually is a message
    if (message.length > 0) {
      // write the message to the db and wait till completed
      await messages.push().set({
        "isSent": true,
        "message": message,
        "timestamp": timestamp,
        "sender": {"name": user.name, "id": user.userID}
      });

      //update the meta information
      if (message.length > 20) {
        //if its a long message only take the first 17 characters
        message = message.substring(0, 17).padRight(3, "...");
      }

      var users = (await chat.child("users").once()).value;
      String type = (await chat.child("type").once()).value;
      String name = (await chat.child("name").once()).value;

      // add the current user to the list of users for notifying
      users[user.userID] = true;

      // need to set in order to trigger the notification
      await chat.set({
        "sender": user.userID,
        "isActive": true,
        "lastMessage": user.name + ": " + message,
        "timestamp": timestamp,
        "users": users,
        "type": type,
        "name": name
      });

      // All done return true to signify success.
      return true;
    }
    return false;
  }

  /// CASE 2:
  // Sanity check:
  if (imageFiles.length > 0) {


    //upload all the images
    imageFiles.forEach((file) async {

      bool isLast = (file == imageFiles[imageFiles.length-1]);

      // save the message to the database
      DatabaseReference path = await writeImageMessageToDB(
          messageRef: messages,
          user: user,
          message: message,
          includeMessage: isLast);

      // now upload each of them
      uploadFile(
          imageFile: file,
          path: path);
    });

    // update the meta information:

    if (message.length > 20) {
      message = message.substring(0, 17).padRight(3, "...");
    }
    // Need to update the meta info on the chat
    String preview = message != "" ? message : "[Image]";

    var users = (await chat.child("users").once()).value;
    String type = (await chat.child("type").once()).value;
    String name = (await chat.child("name").once()).value;
    users[user.userID] = true;

    // need to set in order to trigger the notification
    await chat.set({
      "sender": user.userID,
      "isActive": true,
      "lastMessage": user.name + ": " + preview,
      "timestamp": timestamp,
      "users": users,
      "type": type,
      "name": name
    });

    return true;
  }

  // case where it fell all the way through. must have some failure
  return false;
}

uploadFile(
    {File imageFile,
    DatabaseReference path}) {
  int random = new Random().nextInt(1000000);
  String safePath = path.path.replaceAll("/", "&");
  String filename = "file_" + random.toString() + "<#>$safePath.jpg";
  StorageReference ref = FirebaseStorage.instance.ref().child(filename);

  StorageUploadTask uploadTask = ref.put(imageFile);

  uploadTask.future.then((UploadTaskSnapshot snap) {
    //write the download url to the database
    String downloadUrl = snap.downloadUrl.toString();



    path.child("image").set(downloadUrl);

    path.update({
      "isSent": true,
    });
  });
}

Future<DatabaseReference> writeImageMessageToDB(
    {DatabaseReference messageRef,
    User user,
    String message,
    bool includeMessage}) async {
  DatabaseReference path = messageRef.push();
  path.set({
    "timestamp": new DateTime.now().millisecondsSinceEpoch,
    "isSent": false,
    "message": includeMessage ? (message != "" ? message : null) : null,
    "sender": {"name": user.name, "id": user.userID}
  });
  return path;
}

Future<bool> saveFile(String url, DatabaseReference ref, User user) async {
  await ref.push().set({
    "timestamp": new DateTime.now().millisecondsSinceEpoch,
    "file": url,
    "sender": {"name": user.name, "id": user.userID}
  });
  return true;
}

String convertToTimeString(DateTime d,
    {bool abbreviated = false, bool timeOn = true, bool full = false}) {
  DateTime now = new DateTime.now();

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  String month = months[d.month - 1];
  if (abbreviated) {
    month = month.substring(0, 3);
  }
  String day = d.day.toString();
  String year = d.year.toString();

  int hour = d.hour == 0 ? 1 : d.hour;
  bool isAm;
  if (d.hour > 12) {
    isAm = false;
    hour -= 12;
  } else {
    isAm = true;
  }

  String min;

  if (d.minute < 10) {
    min = "0" + d.minute.toString();
  } else {
    min = d.minute.toString();
  }

  String time = hour.toString() + ":" + min;

  time += isAm ? " AM" : " PM";

  String _day = "";
  //if same day only show time
  if (d.day == now.day && d.month == now.month && d.year == now.year && !full) {
    // same day
    return time;
  } else {
    _day = month + " " + day + ", " + year + (timeOn ? " " + time : "");
  }

  return _day;
}

Comparator<DataSnapshot> sortByTime = (a, b) {
  DateTime d1 = new DateTime.fromMillisecondsSinceEpoch(a.value['timestamp']);
  DateTime d2 = new DateTime.fromMillisecondsSinceEpoch(b.value['timestamp']);

  return d2.compareTo(d1);
};
