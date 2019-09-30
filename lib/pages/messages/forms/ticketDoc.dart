import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:http/http.dart' as http;
import 'package:mor_release/pages/messages/forms/dmDialog.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class DocForm extends StatefulWidget {
  final String type;
  final String distrId;
  final bool docBase;
  final String docProblem;

  DocForm(this.type, this.distrId, this.docBase, this.docProblem, {Key key})
      : super(key: key);

  _DocFormState createState() => _DocFormState();
}

class _DocFormState extends State<DocForm> {
  bool isDocBased = false;
  bool isItemChips = false;
  String docIdSelectedValue;
  String docTypeSelectedValue;
  bool _isAsync = false;
  static var tempVal = [];
  List<TicketDoc> docs = [];
  var items = [];

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormFieldState> _specifyTextFieldKey =
      GlobalKey<FormFieldState>();

  Ticket _newTicketData = Ticket(
      id: null,
      ticketId: null,
      type: null,
      user: null,
      member: null,
      open: null,
      openDate: null,
      closeDate: null,
      docId: null,
      content: null,
      items: []);

  @override
  void initState() {
    if (widget.docBase && widget.docProblem != null) {
      isloading(true);

      getTicketDocs(widget.distrId, widget.docProblem).then((d) {
        docs = d;
        setState(() {
          isDocBased = widget.docBase;
          isloading(false);
        });
      });
    }
    setState(() {
      isDocBased = widget.docBase;
      openItemChips(false);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: FormBuilder(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Text("${widget.type}"),
                  isDocBased
                      ? FormBuilderCustomField(
                          attribute: "doc",
                          validators: [
                            FormBuilderValidators.required(),
                          ],
                          formField: FormField(
                              //initialValue: docs[0].docId,
                              // key: _formKey,
                              enabled: true,
                              builder: (FormFieldState<dynamic> field) {
                                return ScopedModelDescendant<MainModel>(
                                  builder: (BuildContext context, Widget child,
                                      MainModel model) {
                                    return InputDecorator(
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            top: 2.0, bottom: 0.0),
                                        border: InputBorder.none,
                                        errorText: field.errorText,
                                      ),
                                      child: DropdownButton(
                                        hint: Center(
                                          child: Text(
                                            "رقم الفتورة",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        isExpanded: true,
                                        items: docs.map((option) {
                                          return DropdownMenuItem(
                                              child: Center(
                                                child: Text(
                                                  "${option.docId}" +
                                                      " - " +
                                                      "${option.totalVal}" +
                                                      " " +
                                                      "Dh",
                                                  style: TextStyle(
                                                      backgroundColor:
                                                          Colors.yellow[100],
                                                      fontSize: 12.6,
                                                      color: Colors.grey[800],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              value: option.docId);
                                        }).toList(),
                                        value: field.value,
                                        onChanged: (value) {
                                          field.didChange(value);

                                          openItemChips(false);
                                          isloading(true);
                                          getDocItems(value).then((i) {
                                            items = i;
                                            isloading(false);
                                            openItemChips(true);
                                          });
                                          _newTicketData.docId = value;
                                          // print('docId selected Value:$value');

                                          // int x = types.indexOf(value);
                                        },
                                      ),
                                    );
                                  },
                                );
                              }),
                        )
                      : Container(),
                  isItemChips
                      ? FormBuilderChipsInput(
                          decoration: InputDecoration(labelText: "الاصناف"),
                          attribute: 'chips',
                          // readonly: true,

                          //valueTransformer: (val) => val.length > 0 ? val[0] : null,
                          //initialValue: [],
                          maxChips: items.length,
                          onChanged: _onChanged,
                          findSuggestions: (String query) {
                            if (query.length != 0) {
                              var lowercaseQuery = query.toLowerCase();
                              return items.where((profile) {
                                return profile.itemId
                                        .toLowerCase()
                                        .contains(query.toLowerCase()) ||
                                    profile.itemId
                                        .toLowerCase()
                                        .contains(query.toLowerCase());
                              }).toList(growable: false)
                                ..sort((a, b) => a.itemId
                                    .toLowerCase()
                                    .indexOf(lowercaseQuery)
                                    .compareTo(b.itemId
                                        .toLowerCase()
                                        .indexOf(lowercaseQuery)));
                            } else {
                              return const <TicketItem>[];
                            }
                          },

                          chipBuilder: (context, state, profile) {
                            return SingleChildScrollView(
                              child: Flex(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  Expanded(
                                      // fit: FlexFit.tight,
                                      flex: 1,
                                      child: Container(
                                          height: 45,
                                          width: 200,
                                          child: SizedBox(
                                            height: 200,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              children: <Widget>[
                                                Container(
                                                  width: 210,
                                                  child: Row(
                                                    verticalDirection:
                                                        VerticalDirection.down,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      profile.dmQty != 1
                                                          ? IconButton(
                                                              icon: Icon(
                                                                Icons.remove,
                                                                size: 21,
                                                                color: Colors
                                                                    .red[900],
                                                              ),
                                                              onPressed: () =>
                                                                  setState(() =>
                                                                      profile
                                                                          .dmQty--),
                                                            )
                                                          : Container(),
                                                      InputChip(
                                                        key: ObjectKey(profile),
                                                        label: Text(
                                                          profile.itemId,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .pink[900],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        avatar: CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .yellow[100],
                                                          child: Text(
                                                            profile.dmQty
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        onDeleted: () =>
                                                            state.deleteChip(
                                                                profile),
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      profile.dmQty <
                                                              profile.qty
                                                          ? IconButton(
                                                              icon: Icon(
                                                                Icons.add,
                                                                size: 21,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              onPressed: () =>
                                                                  setState(() =>
                                                                      profile
                                                                          .dmQty++))
                                                          : Container(),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )))
                                ],
                              ),
                            );
                          },
                          suggestionBuilder: (context, state, profile) {
                            return ListTile(
                              key: ObjectKey(profile),
                              /* leading: CircleAvatar(
                          backgroundImage: NetworkImage(profile.ticketType),
                        ),*/
                              title: Text(
                                profile.itemId,
                                style: TextStyle(
                                    color: Colors.pink[900],
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(profile.qty.toInt().toString()),
                              onTap: () => state.selectSuggestion(profile),
                            );
                          },
                        )
                      : Container(),
                ],
              )),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.pink[900],
                size: 32,
              ),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                //_formKey.currentState.fields['chips'].currentState.reset();
                //openItemChips(false);
                //  _formKey.currentState.fields['chips'].currentState.reset();
                //  _formKey.currentState.fields['doc'].currentState.reset();
                // openItemChips(true);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.green,
                size: 32,
              ),
              onPressed: () async {
                // print(selectedValue);
                Navigator.of(context, rootNavigator: true).pop();
              },
            )
          ],
        ),
      ),
      inAsyncCall: _isAsync,
      opacity: 0.0,
      progressIndicator: ColorLoader2(),
    );
  }

  ValueChanged _onChanged = (val) {
    val.forEach((t) => print("${t.itemId} => ${t.dmQty}"));
  };

  void isloading(bool i) {
    setState(() {
      _isAsync = i;
    });
  }

  Future<List<TicketDoc>> getTicketDocs(
      String distrId, String docProblem) async {
    List<TicketDoc> docs = [];
    //List productlist;
    List<dynamic> docList;
    dynamic response;
    if (docProblem == 'm' || docProblem == 'd') {
      response = await http.get(
          'http://mywayapi.azurewebsites.net/api/missingordamageditems/$distrId');
      print('running Missing or damaged invoice: $docProblem');
    } else {
      response = await http.get(
          'http://mywayapi.azurewebsites.net/api/getlateinvoices/$distrId');
      print('running late invoice: $docProblem');
    }
    if (response.statusCode == 200) {
      docList = json.decode(response.body) as List;
    }
    docs = docList
        .map((i) => TicketDoc.toJson(i))
        .where((doc) => doc.retrunDoc == '0' && doc.totalVal > 0)
        .toList();
    //print('docs count :${docs.length}');
    return docs;
  }

  Future<List<TicketItem>> getDocItems(String docId) async {
    List<TicketItem> items = [];
    //List productlist;
    List<dynamic> itemsList;
    dynamic response;

    response = await http
        .get('http://mywayapi.azurewebsites.net/api/getinvoicedetails/$docId');

    if (response.statusCode == 200) {
      itemsList = json.decode(response.body) as List;
    }
    items = itemsList
        .map((i) => TicketItem.toJson(i))
        .where((i) => i.itemId.length == 4)
        .toList();
    print('items count :${items.length}');
    return items;
  }

  openItemChips(bool o) {
    setState(() {
      isItemChips = o;
      print("isItemChips:$o");
    });
  }
}
