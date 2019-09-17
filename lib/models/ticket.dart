import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Ticket {
  String key;
  var id;
  String ticketId;
  String type;
  var user;
  bool open;
  String member;
  String openDate;
  String closeDate;
  String docId;
  String content;
  List items;

  Ticket(
      {this.id,
      this.ticketId,
      this.type,
      this.user,
      this.open,
      this.member,
      this.openDate,
      this.closeDate,
      this.docId,
      this.content,
      this.items});

  Ticket.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value['id'],
        ticketId = snapshot.value['ticketId'],
        type = snapshot.value['type'],
        user = snapshot.value['user'],
        open = snapshot.value['open'],
        member = snapshot.value['member'],
        openDate = snapshot.value['openDate'],
        closeDate = snapshot.value['closeDate'],
        docId = snapshot.value['docId'],
        content = snapshot.value['content'],
        items = snapshot.value['items'];

  factory Ticket.fromJson(Map<dynamic, dynamic> json) {
    return Ticket(
      id: json['id'],
      ticketId: json['ticketId'],
      type: json['type'],
      user: json['user'],
      open: json['open'],
      member: json['member'],
      openDate: json['openDate'],
      closeDate: json['closeDate'],
      docId: json['docId'],
      content: json['content'],
      items: json['items'],
    );
  }
}

class Notify {
  String key;
  String title;
  String image;
  String body;
  bool seen;

  Notify({this.key, this.body, this.image, this.title, this.seen});

  Notify.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        body = snapshot.value['body'],
        image = snapshot.value['image'],
        title = snapshot.value['title'],
        seen = snapshot.value['seen'];

  factory Notify.fromJson(Map<dynamic, dynamic> json) {
    return Notify(
        body: json['body'],
        image: json['image'],
        seen: json['seen'],
        title: json['title']);
  }
  toJson() {
    return {
      "body": body,
      "title": title,
      "image": image,
      "seen": seen,
    };
  }
}
