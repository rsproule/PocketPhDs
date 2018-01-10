import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pocketphds/User.dart';
import 'package:firebase_analytics/firebase_analytics.dart';      // new


Future<bool> sendMessage(
    {String message,
    User user,
    String chatKey,
    List<File> imageFiles,
    List<File> files}) async {
  final analytics = new FirebaseAnalytics();     // new
  analytics.logEvent(name: "sendMessage");
  DatabaseReference root = FirebaseDatabase.instance.reference();

  DatabaseReference messages = root.child('messages').child(chatKey);
  DatabaseReference chat = root.child("chats").child(chatKey);

  var timestamp = new DateTime.now().millisecondsSinceEpoch;

//  List<String> imageUrls = [];
//  if (imageFiles.length > 0) {
//    List<Future<String>> imageFutures = [];
//    //create the iterable of type future
//    imageFiles.forEach((file) {
//      imageFutures.add(uploadFile(file));
//    });
//
//    // waits for all the futures to return a list of their results(Strings)
//    imageUrls = await Future.wait(imageFutures);
//    imageUrls.remove("FILE TOO BIG");
//  }

  if (message != "") {
    // send string up to cloud for some cleaning

  }
  List<String> fileCloudRefs = [];
  if (files.length > 0) {
    List<Future<String>> _fileFutures = [];
    files.forEach((file) {
      _fileFutures.add(uploadFile(file, ""));
    });

    fileCloudRefs = await Future.wait(_fileFutures);
  }

  if (imageFiles.length + fileCloudRefs.length < 2 &&
      imageFiles.length + fileCloudRefs.length > 0) {
    DatabaseReference msgRef = messages.push();

    await msgRef.set({
      "message": message.length > 0 ? message : null,
      "timestamp": timestamp,
      "image": imageFiles.length > 0 ? "saving.gif" : null,
      "thumbnail": imageFiles.length > 0 ? "saving.gif" : null,
      "file": fileCloudRefs.length > 0 ? fileCloudRefs[0] : null,
      "sender": {"name": user.name, "id": user.userID}
    });

    if (imageFiles.length > 0) {
      // upload the only image
      uploadFile(imageFiles[0], msgRef.path);
    }
  } else {
    if (message.length > 0) {
      await messages.push().set({
        "message": message,
        "timestamp": timestamp,
        "sender": {"name": user.name, "id": user.userID}
      });
    } else {
      return false;
    }

    //upload all the images
    imageFiles.forEach((file) async {
      String path = await saveImage(messages, user);
      uploadFile(file, path);
    });

    // upload all the files
    List<Future<bool>> fileSaveJobs = [];
    fileCloudRefs.forEach((url) {
      fileSaveJobs.add(saveFile(url, messages, user));
    });

    await Future.wait(fileSaveJobs);
  }

  if (message.length > 20) {
    message = message.substring(0, 17).padRight(3, "...");
  }
  // Need to update the meta info on the chat
  String preview =
      message != "" ? message : imageFiles.length > 0 ? "[Image]" : "[File]";

  var users = (await chat.child("users").once()).value;

  String type = (await chat.child("type").once()).value;
  String name = (await chat.child("name").once()).value;
  users[user.userID] = true;
  // need to set in order to trigger the notification
  await chat.set({
    "sender" : user.userID,
    "isActive" : true,
    "lastMessage" : user.name + ": " + preview,
    "timestamp" : timestamp,
    "users" : users,
    "type" : type,
    "name" : name
  });

  return true;
}

Future<String> uploadFile(File f, String path) async {
  int random = new Random().nextInt(1000000);
  String safePath = path.replaceAll("/", "%");
  String filename = "file_" + random.toString() + "<#>$safePath.jpg";
  StorageReference ref = FirebaseStorage.instance.ref().child(filename);

  StorageUploadTask uploadTask = ref.put(f);

  await uploadTask.future;
  return filename;
}

Future<String> saveImage(DatabaseReference ref, User user) async {
  DatabaseReference path = ref.push();

  path.set({
    "timestamp": new DateTime.now().millisecondsSinceEpoch,
    "image": "saving.gif",
    "image_thumbnail": "saving.gif",
    "sender": {"name": user.name, "id": user.userID}
  });
  return path.path;
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
