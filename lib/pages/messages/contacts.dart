/*
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../bottom_nav.dart';
import '../const.dart';
import 'chat.dart';

class Contacts extends StatefulWidget {
  final String distrId;

  Contacts({@required this.distrId});

  State createState() => _Contacts();
}

@override
class _Contacts extends State<Contacts> {
  @override
  void initState() {
    supportUser();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // model.messageKeys(model.userInfo.key);
            _asyncInputDialog(context);
          },
          child: Icon(Icons.add_circle_outline),
          backgroundColor: Colors.pink[900],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        appBar: AppBar(
            title: sUser.key == '1'
                ? Container(
                    height: 45,
                    child: RaisedButton(
                      child: Row(children: <Widget>[
                        Material(
                          color: Colors.pink[900],
                          child: sUser.photoUrl != null
                              ? CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 28.0,
                                    height: 28.0,
                                    padding: EdgeInsets.all(1.0),
                                  ),
                                  imageUrl: sUser.photoUrl,
                                  width: 40.0,
                                  height: 40.0,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.tag_faces,
                                  size: 28.0,
                                  color: greyColor,
                                ),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '${sUser.name}',
                                  style: TextStyle(
                                      color: Colors.pink[900],
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 5.0),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(left: 20.0),
                        ),
                      ]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chat(
                                      peerId: int.parse(sUser.key),
                                      peerAvatar: sUser.photoUrl,
                                      ticketId: null,
                                    )));
                      },
                      color: Colors.grey[400],
                      splashColor: Colors.pink[900],
                      padding: EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  )
                : Container()),
        body: WillPopScope(
          child: Stack(
            children: <Widget>[
              // List
              Container(
                child: FutureBuilder(
                  builder: (context, users) {
                    if (!users.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(context, users.data[index]),
                        itemCount: users.data.length,
                      );
                    }
                  },
                  future: model.getContacts(model.userInfo.key),
                ),
              ),

              // Loading
              Positioned(
                child: isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor)),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                    : Container(),
              ),
               ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemBuilder: (context, index) =>
                    buildItem(context, model.userInfo),
                itemCount: 1,
              ),
              Positioned(
                child: isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor)),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                    : Container(),
              )
            ],
          ),
          onWillPop: onBackPress,
        ),
      );
    });
  }

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];
  Future<bool> onBackPress() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BottomNav()));
    return Future.value(false);
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String nodeId = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter member Id'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration:
                    new InputDecoration(labelText: 'member', hintText: '367'),
                onChanged: (value) {
                  nodeId = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(nodeId);
              },
            ),
          ],
        );
      },
    );
  }
  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Widget buildItem(BuildContext context, User user) {
    return user.key != '1'
        ? Container(
            child: FlatButton(
              child: Row(
                children: <Widget>[
                  Material(
                    child: user.photoUrl != null
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 50.0,
                              height: 50.0,
                              padding: EdgeInsets.all(15.0),
                            ),
                            imageUrl: user.photoUrl,
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.tag_faces,
                            size: 50.0,
                            color: greyColor,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '${user.name}',
                              style: TextStyle(
                                  color: Colors.pink[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20.0),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              peerId:
                                  widget.distrId, //TODO: AND TREE MEMBER HERE
                              peerAvatar: user.photoUrl,
                            )));
              },
              color: greyColor2,
              padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
            margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
          )
        : Container();
  }
}

User sUser;
Future<User> supportUser() async {
  final DataSnapshot snapshot = await FirebaseDatabase.instance
      .reference()
      .child('flamelink/environments/production/content/users/en-US')
      .child('1')
      .once();
  sUser = User.fromSnapshot(snapshot);
  print('userData user.distrId:${sUser.distrId}');
  return sUser;
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}


Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }
*/
