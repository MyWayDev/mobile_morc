import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart' as prefix0;
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/const.dart';
import 'package:mor_release/pages/messages/chat.dart';
import 'package:mor_release/pages/messages/forms/ticketDoc.dart';
import 'package:mor_release/pages/messages/forms/ticketSelect.dart';
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
  List<TicketType> types = [];

  String path = "flamelink/environments/stage/content/support/en-US";

  FirebaseDatabase database = FirebaseDatabase.instance;

  DatabaseReference databaseReference;
  Query query;
  var subAdd;
  var subChanged;
  var subDel;
  var subSelect;
  List<DropdownMenuItem> items = [];

  String selectedValue;
  bool isSwitched = true;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getTicketTypes();

    databaseReference = database.reference().child(path);
    widget.distrId != 1
        ? query = databaseReference
            .child('/')
            .orderByChild('user')
            .equalTo(widget.distrId.toString())
        : query = databaseReference.child("/");
    subAdd = query.onChildAdded.listen(_onItemEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
    subDel = query.onChildRemoved.listen(_onItemEntryDeleted);

    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncInputDialog(context);
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    subAdd?.cancel();
    subChanged?.cancel();
    subDel?.cancel();
    subSelect?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    filteredTickets = ticketsData.reversed
        .where((o) =>
            o.open == true || closeDate(o.closeDate) == DateTime.now().month)
        .toList();
    return Scaffold(
      floatingActionButton: widget.distrId > 5
          ? FloatingActionButton(
              onPressed: () {
                _asyncInputDialog(context);
              },
              child: Icon(
                Icons.add_comment,
                size: 28,
              ),
              backgroundColor: Colors.pink[600],
            )
          : null,
      floatingActionButtonLocation:
          widget.distrId > 5 ? FloatingActionButtonLocation.endDocked : null,
      body: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Stack(
          children: <Widget>[
            Container(
                child: ListView.builder(
              padding: EdgeInsets.all(5),
              itemBuilder: (context, index) {
                return Card(
                    color: !filteredTickets[index].open
                        ? Colors.greenAccent[100]
                        : Colors.pink[100],
                    child: ExpansionTile(
                      leading: ConstrainedBox(
                        constraints: BoxConstraints.tight(Size(40, 40)),
                        child: Switch(
                          value: filteredTickets[index].open,
                          onChanged: (value) {
                            setState(() {
                              filteredTickets[index].open = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ),
                      backgroundColor: !filteredTickets[index].open
                          ? Colors.greenAccent[100]
                          : Colors.pink[100],
                      key: PageStorageKey<Ticket>(filteredTickets[index]),
                      title: buildItem(context, filteredTickets[index]),
                      children: <Widget>[
                        buildTicketInfo(context, filteredTickets[index]),
                      ],
                    ));
              },
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
    if (widget.distrId <= 5) {
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
                      ListTile(
                        leading: Column(
                          children: <Widget>[
                            Text(
                              ticket.id.toString(),
                              style: TextStyle(
                                  color: Colors.pink[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Text(ticket.type),
                          ],
                        ),
                        /*  title: ListTile(
                          title: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.vpn_key,
                                  color: Colors.pink[900],
                                  size: 18,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                ),
                                Text(
                                  int.parse(ticket.member).toString(),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(ticket.type),
                        ),*/
                        trailing: Column(
                          children: <Widget>[
                            Text(
                              int.parse(ticket.member).toString(),
                              style: TextStyle(
                                  color: Colors.pink[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(prefix0.DateFormat("dd-MM-yyy")
                                .format(DateTime.parse(ticket.openDate))),
                            Text(prefix0.DateFormat("H:mm")
                                .format(DateTime.parse(ticket.openDate))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // margin: EdgeInsets.only(left: 5.0),
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
                                    fontSize: 14),
                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                            ),
                            Text(ticket.content)
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
    setState(() {});
  }

  void _onItemEntryDeleted(Event event) {
    Ticket tick =
        ticketsData.firstWhere((f) => f.id == event.snapshot.value['id']);

    setState(() {
      ticketsData.remove(ticketsData[ticketsData.indexOf(tick)]);
    });
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

  getTicketTypes() async {
    DataSnapshot snapshot = await database
        .reference()
        .child('flamelink/environments/stage/content/ticketType/en-US/')
        .once();
    Map<dynamic, dynamic> typeList = snapshot.value;
    List list = typeList.values.toList();
    types = list.map((f) => TicketType.toJosn(f)).toList();
    String valueConcat(String type, bool docBased) {
      var pValue = "${docBased.toString().substring(0, 1)}$type";
      print(pValue);
      return pValue;
    }

    if (snapshot.value != null) {
      for (var t in types) {
        items.add(DropdownMenuItem(
          child: Text(
            t.ticketType,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          value: valueConcat(t.ticketType, t.docBased),
        ));
      }
    } else {
      types = [];
    }
  }

  //void _onData(Event event) {}

  _asyncInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return TicketSelect(types, widget.distrId.toString().padLeft(8, '0'));
      },
    );
  }

  List<String> litems = ["1", "2", "Third", "4"];

  Widget buildTicketInfo(BuildContext context, Ticket ticket) {
    return ExpansionTile(
        key: PageStorageKey<Ticket>(ticket),
        backgroundColor:
            !ticket.open ? Colors.greenAccent[100] : Colors.pink[100],
        title: Column(
          children: <Widget>[
            Text(
              ticket.docId,
              style: TextStyle(
                  color: Colors.pink[900], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: ticket.items.map(_buildTicketItems).toList());
  }

  Widget _buildTicketItems(item) {
    return Text(item['itemId']);
  }
}
