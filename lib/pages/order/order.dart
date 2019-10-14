import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/stock_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderPage();
  }
}

@override
class _OrderPage extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Column(children: <Widget>[
            model.itemorderlist.length != 0
                ? Container(
                    // decoration: BoxDecoration(color: Colors.grey[350]),
                    child: Card(
                    color: Colors.grey[350],
                    elevation: 5,
                    child: ListTile(
                        leading: Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                              ),
                              Text(
                                'Dh ${model.orderSum().toString()}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' Bp ${model.orderBp().toString()}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'الاجمالى',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: RawMaterialButton(
                          child: Icon(
                            Icons.send,
                            size: 24.0,
                            color: Colors.white,
                          ),
                          shape: CircleBorder(),
                          highlightColor: Colors.pink[900],
                          elevation: 3,
                          fillColor: Colors.green,
                          onPressed: () {
                            Navigator.pushNamed(context, '/endorder');
                            model.loading = false;
                          },
                          splashColor: Colors.pink[900],
                        )),
                  ))
                : Container(),
            Expanded(
                child: model.itemorderlist.length != 0
                    ? ListView.builder(
                        itemCount: model.itemorderlist.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Dismissible(
                              onDismissed: (DismissDirection direction) {
                                if (direction == DismissDirection.endToStart) {
                                  model.deleteItemOrder(i);
                                  model.itemCount();
                                } else if (direction ==
                                    DismissDirection.startToEnd) {
                                  model.deleteItemOrder(i);
                                  model.itemCount();
                                }
                              },
                              background: Container(
                                color: Colors.grey[50],
                              ),
                              key: Key(model.displayItemOrder[i].itemId),
                              child: Column(
                                children: <Widget>[
                                  Card(
                                    elevation: 8,
                                    child: ListTile(
                                      //   trailing: _buildIconButton(context, i, model),
                                      // contentPadding: EdgeInsets.only(top: 10.0),
                                      leading: CircleAvatar(
                                        minRadius: 36,
                                        maxRadius: 42,
                                        backgroundColor: Colors.purple[50],
                                        backgroundImage: NetworkImage(
                                          model.itemorderlist[i].img,
                                        ),
                                      ),
                                      title: Row(children: <Widget>[
                                        Container(
                                          child: Flexible(
                                            flex: 1,
                                            child: Column(children: <Widget>[
                                              Flex(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  direction: Axis.horizontal,
                                                  //  direction: Axis.horizontal,
                                                  children: <Widget>[
                                                    Container(
                                                      width: 41,
                                                      child: Text(
                                                        model.itemorderlist[i]
                                                            .itemId,
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFFFF8C00),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        // width: 113,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 8),
                                                          child: Text(
                                                            model
                                                                .itemorderlist[
                                                                    i]
                                                                .name,
                                                            textDirection:
                                                                TextDirection
                                                                    .rtl,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 15.0,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        )),
                                                  ]),
                                              Center(
                                                  child: Text(
                                                'اجمالى الصنف',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              )),
                                              Divider(
                                                height: 3.0,
                                                indent: 0,
                                                color: Colors.blueGrey,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ]),
                                      subtitle: Row(
                                        children: <Widget>[
                                          Container(
                                            child: Flexible(
                                              flex: 1,
                                              child: Column(
                                                children: <Widget>[
                                                  Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        Text(
                                                          'Dh ${model.itemorderlist[i].totalPrice.toString()}',
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .green[700],
                                                          ),
                                                        ),
                                                        _buildIconButton(
                                                            context, i, model),
                                                        Text(
                                                          'Bp ${model.itemorderlist[i].totalBp.toString()}',
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            color:
                                                                Colors.red[900],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        },
                      )
                    : Center(
                        child: Icon(
                        Icons.remove_shopping_cart,
                        size: 80.5,
                        color: Colors.grey[300],
                      ))),
          ]));
    });
  }
}

//double orderPlus(double orderSum, int courierFee, int bpLimit) {}

Widget _buildIconButton(BuildContext context, int i, MainModel model) {
  return BadgeIconButton(
    itemCount: model.itemorderlist[i].qty <= 0
        ? 0
        : model.itemorderlist[i].qty, // required
    icon: Icon(
      Icons.shopping_cart,
      color: Colors.grey[600],
      size: 32.0,
    ), // required
    //badgeColor: Colors.pink[900],
    badgeTextColor: Colors.white,
    onPressed: () async {
      showDialog(
          context: context,
          builder: (_) => StockDialog(model.itemData, model.getItemIndex(i),
              model.itemorderlist[i].qty));
    },
  );
}
