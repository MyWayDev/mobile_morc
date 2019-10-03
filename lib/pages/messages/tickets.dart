import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
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
                  child: Column(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(
                            Icons.vpn_key,
                            size: 21,
                            color: Colors.pink[900],
                          ),
                          title: Text(
                            filteredTickets[index].member,
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                size: 21,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                              ),
                              Text(
                                prefix0.DateFormat("H:mm").format(
                                    DateTime.parse(
                                        filteredTickets[index].openDate)),
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 6),
                              ),
                              Text(
                                prefix0.DateFormat("dd-MM-yyy").format(
                                    DateTime.parse(
                                        filteredTickets[index].openDate)),
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          )),
                      ExpansionTile(
                        leading: widget.distrId <= 5
                            ? ConstrainedBox(
                                constraints: BoxConstraints.tight(Size(45, 40)),
                                child: Switch(
                                  value: filteredTickets[index].open,
                                  onChanged: (value) {
                                    _closeTicket(
                                        filteredTickets[index].key, value);
                                    /* setState(() {
                                  filteredTickets[index].open = value;
                                });*/
                                  },
                                  activeTrackColor: Colors.white,
                                  activeColor: Colors.pink[900],
                                  inactiveThumbColor: Colors.grey,
                                ),
                              )
                            : Icon(
                                Icons.add_comment,
                              ),
                        backgroundColor: !filteredTickets[index].open
                            ? Colors.greenAccent[100]
                            : Colors.pink[100],
                        key: PageStorageKey<Ticket>(filteredTickets[index]),
                        title: buildItem(context, filteredTickets[index]),
                        children: <Widget>[
                          buildTicketInfo(context, filteredTickets[index]),
                        ],
                      )
                    ],
                  ),
                );
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Column(
                          children: <Widget>[
                            Text(
                              ticket.id.toString(),
                              softWrap: true,
                              style: TextStyle(
                                  color: Colors.pink[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Text(
                              ticket.type,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // margin: EdgeInsets.only(left: 18.0),
                ),
              )
            ],
          ),
          onPressed: () {
            ticket.open
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              peerId: int.parse(ticket.user),
                              peerAvatar:
                                  "https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1568595588253_account-img.png?alt=media&token=3d4fa5c4-5099-49ac-b621-96b5ea4cd5bd",
                              ticketId: ticket.id,
                            )))
                : null;
          },
          //padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          //  shape:
          //    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        //   margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
      );
    } else {
      return ticket.user == widget.distrId.toString()
          ? Container(
              child: FlatButton(
                color:
                    !ticket.open ? Colors.greenAccent[100] : Colors.pink[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              //   alignment: Alignment.centerLeft,
                              //   margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                            ),
                            Text(ticket.type)
                          ],
                        ),
                        //  margin: EdgeInsets.only(left: 15.0),
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  ticket.open
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Chat(
                                    peerId: 1,
                                    peerAvatar:
                                        "https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1568468553357_myway.png?alt=media&token=bd51c423-9967-4075-bb8b-3f2fbee1e9dd",
                                    ticketId: ticket.id,
                                  )))
                      : null;
                },
                // padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                ////   borderRadius: BorderRadius.circular(10.0)),
              ),
              //  margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
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

  Widget buildTicketInfo(BuildContext context, Ticket ticket) {
    return ExpansionTile(
      key: PageStorageKey<Ticket>(ticket),
      backgroundColor:
          !ticket.open ? Colors.greenAccent[100] : Colors.pink[100],
      leading: Icon(GroovinMaterialIcons.file),
      title: Column(
        children: <Widget>[
          Text(
            ticket.docId ?? "",
            style: TextStyle(color: Colors.pink[900], fontSize: 14),
          ),
          Text(
            ticket.content,
            textDirection: TextDirection.rtl,
            softWrap: true,
            style: TextStyle(fontSize: 14, wordSpacing: 0.1),
          ),
          ticket.items.length != 0
              ? Divider(
                  color: Colors.black,
                )
              : Container(),
          ticket.items.length != 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_downward,
                      size: 18,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                    ),
                    Text(
                      "قائمة الاصناف",
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                )
              : Container()
        ],
      ),
      children: ticket.items.map(_buildTicketItems).toList(),
    );
  }

  Widget _buildTicketItems(item) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(115, 43)),
      child: ListTile(
        title: Text(
          item['itemId'] ?? "",
          style: TextStyle(fontSize: 13),
        ),
        trailing: Text(
          item['qty'] ?? "",
          style: TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  _closeTicket(String key, bool value) {
    databaseReference.child(key).update({'open': value});
  }
}
