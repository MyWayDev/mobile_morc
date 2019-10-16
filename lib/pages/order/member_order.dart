import 'package:flutter/material.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/pages/order/widgets/order_courier.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class MemberOrder extends StatefulWidget {
  final Future<List<dynamic>> couriers;
  final String areaId;
  MemberOrder(this.couriers, this.areaId);
  @override
  State<StatefulWidget> createState() {
    return _MemberOrder();
  }
}

@override
class _MemberOrder extends State<MemberOrder> {
  List<Courier> shipment = [];
  @override
  void initState() {
    getinit();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getinit() async {
    shipment = await widget.couriers;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return shipment.length > 0
            ? CourierOrder(shipment, widget.areaId, model.userInfo.distrId,
                model.userInfo.distrId)
            : Container();
      },
    );
  }
}
/*
FlatButton.icon(
                              label: Text('Test Code'),
                              icon: Icon(
                                Icons.playlist_add_check,
                                size: 20.0,
                              ),
                              onPressed: () async {
                                model.saveOrder('00000002');
                              },
                            ),
FlatButton.icon(
                          label: Text('Test Code'),
                          icon: Icon(
                            Icons.playlist_add_check,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            await model.checkGift(
                                model.orderBp(), model.giftBp());
                            model.getGiftPack();
//model.courierService('00000002', '25');
                            //  model.courierList('25');
                          },
                        ),
                        Container(
                              child: DropdownButton<Courier>(
                                iconSize: 40.0,
                                elevation: 5,
                                //isDense: true,
                                value: _courier == null
                                    ? null
                                    : shipment[_courier],
                                items: shipment.map((Courier courier) {
                                  return DropdownMenuItem<Courier>(
                                      value: courier,
                                      child: Text(
                                        courier.name,
                                        style: new TextStyle(
                                            textBaseline:
                                                TextBaseline.ideographic,
                                            color: Colors.pink[900],
                                            fontWeight: FontWeight.bold),
                                      ));
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    _courier = shipment.indexOf(value);
                                    print(value.courierId);
                                  });
                                },
                              ),

                              // Text(model.nodeJsonData.areaId),
                            ),
                        */
