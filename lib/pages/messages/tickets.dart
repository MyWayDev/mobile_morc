import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/pages/const.dart';
import 'package:mor_release/pages/messages/chat.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class Tickets extends StatefulWidget {
  final int distrId;
  Tickets({@required this.distrId});

  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  List<Ticket> ticketsData = List();
  List<Ticket> filteredTickets = [];

  String path = "flamelink/environments/stage/content/support/en-US";
  FirebaseDatabase database = FirebaseDatabase.instance;

  DatabaseReference databaseReference;
  Query query;
  var subAdd;
  var subChanged;
  var subDel;
  var subSelect;
  @override
  void initState() {
    super.initState();
    print('ticket distrId: ${widget.distrId}');
    databaseReference = database.reference().child(path);
    widget.distrId != 1
        ? query = databaseReference
            .child('/')
            .orderByChild('user')
            .equalTo(widget.distrId.toString())
        : query = databaseReference.child("/");
    // Query queryII = query.orderByChild('open').equalTo(true).limitToLast(2);

    //subSelect = query.onValue.listen(_onData);
    subAdd = query.onChildAdded.listen(_onItemEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
    subDel = query.onChildRemoved.listen(_onItemEntryDeleted);
  }

  @override
  void dispose() {
    super.dispose();
    subAdd?.cancel();
    subChanged?.cancel();
    subDel?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    filteredTickets = ticketsData.reversed
        .where((o) =>
            o.open == true || closeDate(o.closeDate) == DateTime.now().month)
        .toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _asyncInputDialog(context);
        },
        child: Icon(
          Icons.add_comment,
          size: 28,
        ),
        backgroundColor: Colors.pink[600],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Stack(
          children: <Widget>[
            Container(
                child: ListView.builder(
              padding: EdgeInsets.all(5),
              itemBuilder: (context, index) =>
                  buildItem(context, filteredTickets[index]),
              itemCount: filteredTickets.length,
            )),
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
      ),
    );
  }

  bool isLoading = false;
  Widget buildItem(BuildContext context, Ticket ticket) {
    if (widget.distrId == 1) {
      return Container(
        child: FlatButton(
          color: !ticket.open ? Colors.greenAccent[100] : Colors.pink[100],
          child: Row(
            children: <Widget>[
              /* Material(
              child: ticket. != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      ),
                      imageUrl: ticket['Photo'],
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
            ),*/
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${ticket.id}',
                          style: TextStyle(
                              color: Colors.pink[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                      ),
                      Text('${ticket.content}....${ticket.user.toString()}')
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              )
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: int.parse(ticket.user),
                          peerAvatar:
                              "https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1568595588253_account-img.png?alt=media&token=3d4fa5c4-5099-49ac-b621-96b5ea4cd5bd",
                          ticketId: ticket.id,
                        )));
          },
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
      );
    } else {
      return ticket.user == widget.distrId.toString()
          ? Container(
              child: FlatButton(
                color:
                    !ticket.open ? Colors.greenAccent[100] : Colors.pink[100],
                child: Row(
                  children: <Widget>[
                    /* Material(
              child: ticket. != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      ),
                      imageUrl: ticket['Photo'],
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
            ),*/
                    Flexible(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                '${ticket.id}',
                                style: TextStyle(
                                    color: Colors.pink[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                            ),
                            Text(
                                '${ticket.content}....${ticket.user.toString()}')
                          ],
                        ),
                        margin: EdgeInsets.only(left: 20.0),
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                                peerId: 1,
                                peerAvatar:
                                    "https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1568468553357_myway.png?alt=media&token=bd51c423-9967-4075-bb8b-3f2fbee1e9dd",
                                ticketId: ticket.id,
                              )));
                },
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
            )
          : Container();
    }
  }

  int closeDate(String closeDate) {
    if (closeDate == '' || closeDate == null) {
      DateTime date = new DateTime(2000);
      closeDate = date.toString();
    }
    var date = DateTime.parse(closeDate);

    return date.month;
  }

  void _onItemEntryAdded(Event event) {
    ticketsData.add(Ticket.fromSnapshot(event.snapshot));
    print('tickets length:${ticketsData.first.ticketId}');
    setState(() {});
    //ticketsData.add(Ticket.fromSnapshot(event.snapshot));
    // items.where((i) => !i.disabled).forEach((f) => itemData.add(f));
    //print("itemData length:${itemData.length}");
  }

  void _onItemEntryDeleted(Event event) {
    Ticket tick =
        ticketsData.firstWhere((f) => f.id == event.snapshot.value['id']);

    setState(() {
      ticketsData.remove(ticketsData[ticketsData.indexOf(tick)]);
    });

    //ticketsData.add(Ticket.fromSnapshot(event.snapshot));
    // items.where((i) => !i.disabled).forEach((f) => itemData.add(f));
    //print("itemData length:${itemData.length}");
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = ticketsData.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      ticketsData[ticketsData.indexOf(oldEntry)] =
          Ticket.fromSnapshot(event.snapshot);
    });
  }
  //void _onData(Event event) {}
}

Future<String> _asyncInputDialog(BuildContext context) async {
  final GlobalKey<FormState> _registrationFormKey = GlobalKey<FormState>();

  String nodeId = '';

  final Map<String, dynamic> _registrationFormData = {
    'email': null,
    'password': null,
    'userId': null,
    'PersonalId': null,
    'telephone': null
  };
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
