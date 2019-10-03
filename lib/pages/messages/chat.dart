import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';

class Chat extends StatelessWidget {
  final int peerId;
  final String peerAvatar;
  final int ticketId;
  final String type;
  final bool isOpen;

  Chat(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.ticketId,
      this.isOpen,
      this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "${ticketId.toString()}  $type",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: ChatScreen(
            id: model.user.key,
            peerId: peerId,
            peerAvatar: peerAvatar,
            ticketId: ticketId,
            type: type,
            isOpen: isOpen,
          ));
    });
  }
}

class ChatScreen extends StatefulWidget {
  final int peerId;
  final String peerAvatar;
  final String id;
  final int ticketId;
  final String type;
  final bool isOpen;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.id,
    @required this.ticketId,
    @required this.type,
    @required this.isOpen,
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
      peerId: peerId,
      peerAvatar: peerAvatar,
      ticketId: ticketId,
      type: type,
      isOpen: isOpen);
}

class ChatScreenState extends State<ChatScreen> {
  bool isOpen;
  String type;
  int peerId;
  String peerAvatar;
  int ticketId;

  ChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.ticketId,
      @required this.type,
      @required this.isOpen});

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  String path = "flamelink/environments/stage/content/messages/en-US/";
  List<Message> _msgList = List();
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  var subAdd;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    readLocal(widget.id);
  }

  @override
  void dispose() {
    super.dispose();
    _peerSeenUpdate(
      database.reference().child("$path/${ticketId.toString()}/$groupChatId"),
    );
    subAdd?.cancel();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  _peerSeenUpdate(DatabaseReference dbref) {
    _msgList.length != 0
        ? _msgList
            .where((m) => m.idTo == widget.id)
            .forEach((k) => dbref.child(k.key).update({"seen": true}))
        : null;
  }

  readLocal(String distrId) {
    // prefs = await SharedPreferences.getInstance();
    //prefs.getString('id') ?? '';
    if (widget.id.hashCode <= peerId.toString().hashCode) {
      groupChatId = '${widget.id}-$peerId';
    } else {
      groupChatId = '$peerId-${widget.id}';
    }

    databaseReference =
        database.reference().child("$path/${ticketId.toString()}/$groupChatId");
    //
    subAdd = databaseReference.onChildAdded.listen(_onMessageEntryAdded);
    setState(() {});
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

/*
var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());*/
      FirebaseDatabase.instance
          .reference()
          .child(path +
              '/${widget.ticketId}/$groupChatId/${DateTime.now().millisecondsSinceEpoch.toString()}')
          .set({
        'idFrom': widget.id,
        'idTo': peerId.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type,
        'seen': false
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, Message msg) {
    if (msg.idFrom == widget.id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          msg.type == 0
              // Text
              ? Container(
                  child: Text(
                    msg.content,
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : msg.type == 1
                  // Image
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return ImageDetails(
                            image: msg.content,
                          );
                        }));
                      },
                      child: Container(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: msg.content,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      ),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'assets/images/${msg.content}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                msg.type == 0
                    ? Container(
                        child: Text(
                          msg.content,
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.pink[800],
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : msg.type == 1
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return ImageDetails(
                                  image: msg.content,
                                );
                              }));
                            },
                            child: Container(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: greyColor2,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: msg.content,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.fill,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              margin: EdgeInsets.only(left: 10.0),
                            ),
                          )
                        : Container(
                            child: Image.asset(
                              'assets/images/${msg.content}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(msg.timeStamp))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom == widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom != widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(isOpen),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildImage(String image) {
    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(image),
      ),
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput(bool isOpen) {
    return isOpen
        ? Container(
            child: Row(
              children: <Widget>[
                // Button send image
                Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 1.0),
                    child: new IconButton(
                      icon: new Icon(
                        Icons.image,
                        size: 28,
                      ),
                      onPressed: getImage,
                      color: Colors.pink[900],
                    ),
                  ),
                  color: Colors.white,
                ),
                /*  Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(
                  Icons.face,
                  size: 28,
                ),
                onPressed: getSticker,
                color: Colors.pink[900],
              ),
            ),
            color: Colors.white,
          ),*/

                // Edit text
                Flexible(
                  child: Container(
                    child: TextField(
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: greyColor),
                      ),
                      focusNode: focusNode,
                    ),
                  ),
                ),

                // Button send message
                Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 8.0),
                    child: new IconButton(
                      icon: new Icon(
                        Icons.send,
                        size: 28,
                      ),
                      onPressed: () =>
                          onSendMessage(textEditingController.text, 0),
                      color: Colors.pink[900],
                    ),
                  ),
                  color: Colors.white,
                ),
              ],
            ),
            width: double.infinity,
            height: 50.0,
            decoration: new BoxDecoration(
                border: new Border(
                    top: new BorderSide(color: greyColor2, width: 0.5)),
                color: Colors.white),
          )
        : Container();
  }

  Widget buildListMessage() {
    //TODO: USE ONE LIST IF U CAN;
    listMessage = _msgList;

    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, revereMsgList(_msgList)[index]),
              itemCount: _msgList.length,
              reverse: true,
              controller: listScrollController,
            ),

      /* */
    );
  }

  List<Message> revereMsgList(List<Message> msgs) {
    List<Message> _msgs = [];
    msgs.reversed.forEach((f) => _msgs.add(f));
    // _msgs.forEach((f) => print(f.timeStamp));
    return _msgs;
  }

  void _onMessageEntryAdded(Event event) {
    _msgList.add(Message.fromSnapshot(event.snapshot));
    setState(() {});
  }
}

class Message {
  String key;
  String content;
  String idFrom;
  String idTo;
  String timeStamp;
  bool seen;
  int type;

  Message({
    this.key,
    this.content,
    this.idFrom,
    this.idTo,
    this.timeStamp,
    this.seen,
    this.type,
  });

  Message.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        content = snapshot.value['content'],
        idFrom = snapshot.value['idFrom'],
        idTo = snapshot.value['idTo'],
        timeStamp = snapshot.value['timestamp'],
        seen = snapshot.value['seen'],
        type = snapshot.value['type'];

  // Map<dynamic,dynamic> msgsSnapshot =  snapshot.value;
  // List msgs = msgsSnapshot.values.toList();
  //List<Message> msgList = msgsSnapshot.map((m)=>Message.fromSnapShot(m)).toList();
}

class ImageDetails extends StatelessWidget {
  final String image;
  ImageDetails({@required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(image),
      ),
      body: Center(
        child: Hero(
            tag: "",
            child: PhotoView(
              imageProvider: NetworkImage(
                image,
              ),
            )),
      ),
    );
  }
}
/*          StreamBuilder(
              stream: FirebaseDatabase.instance
                  .reference()
                  .child(
                      'flamelink/environments/production/content/messages/en-US/1')
                  .onValue,
//! firestore code
              Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.snapshot;
                  // var msg = snapshot.data.snapshot.value.toList().lenght;
                  // print(msg);

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, _msgList[index]),
                    itemCount: _msgList.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ), */
