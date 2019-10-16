import 'package:flutter/material.dart';

import 'package:mor_release/models/courier.dart';
import 'package:mor_release/models/user.dart';

import 'package:mor_release/pages/order/widgets/order_courier.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class NodeOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeOrder();
  }
}

@override
class _NodeOrder extends State<NodeOrder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<FormState> _orderFormKey = GlobalKey<FormState>();

  final Map<String, dynamic> _orderFormData = {
    'id': null,
    'areaId': null,
    'name': null,
  };
  void isLoading() {
    bool o;
    shipment.length > 0 ? o = false : o = true;
    setState(() {
      loading = o;
    });
  }

  bool isTyping;

  void getTyping(MainModel model) {
    setState(() {
      model.isTypeing = isTyping;
    });
  }

  bool loading = false;

  bool veri = false;
  //int _courier;
  User _nodeData;
  Courier selectedCourier;
  List<Courier> shipment = [];

  void resetVeri() {
    controller.clear();
    veri = false;
    shipment = [];
  }

  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: Form(
          key: _orderFormKey,
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
                child: ListTile(
                  //  contentPadding: EdgeInsets.all(0),
                  leading:
                      Icon(Icons.vpn_key, size: 24.0, color: Colors.pink[500]),
                  title: TextFormField(
                    textAlign: TextAlign.center,
                    controller: controller,
                    enabled: !veri ? true : false,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ادخل رقم العضو',
                      hintStyle: TextStyle(color: Colors.grey[400]),

                      //contentPadding: EdgeInsets.all(5.0),
                    ),
                    // controller: ,
                    //autocorrect: true,
                    //autofocus: true,
                    //autovalidate: true,
                    //initialValue: _isleader ? null : model.userInfo.distrId,

                    keyboardType: TextInputType.number,
                    validator: (value) => value.isEmpty
                        ? 'Code is Empty !!'
                        : RegExp('[0-9]').hasMatch(value)
                            ? null
                            : 'invalid code !!',
                    onSaved: (String value) {
                      _orderFormData['id'] = value.padLeft(8, '0');
                    },
                  ),
                  trailing: IconButton(
                    icon: !veri && controller.text.length > 0
                        ? Icon(
                            Icons.check,
                            size: 29.0,
                            color: Colors.blue,
                          )
                        : controller.text.length > 0
                            ? Icon(
                                Icons.close,
                                size: 24.0,
                                color: Colors.grey,
                              )
                            : Container(),
                    color: Colors.pink[900],
                    onPressed: () async {
                      if (!veri) {
                        isTyping = true;
                        getTyping(model);
                        veri = await model.leaderVerification(
                            controller.text.padLeft(8, '0'));
                        if (veri) {
                          isTyping = true;
                          getTyping(model);
                          _nodeData = await model
                              .nodeJson(controller.text.padLeft(8, '0'));
                          controller.text =
                              _nodeData.distrId + '    ' + _nodeData.name;
                          shipment = await model.courierList(_nodeData.areaId);
                        } else {
                          resetVeri();
                          isTyping = false;
                          getTyping(model);
                        }
                      } else {
                        resetVeri();
                        isTyping = false;
                        getTyping(model);
                      }
                    },
                    splashColor: Colors.pink,
                  ),
                ),
              ),
              veri && controller.text.length >= 8 && shipment.length > 0
                  ? Card(
                      color: Colors.grey[100],
                      child: Column(
                        children: <Widget>[
                          //Container(),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        CourierOrder(
                                            shipment,
                                            _nodeData.areaId,
                                            _nodeData.distrId,
                                            model.userInfo.distrId),
                                      ],
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    });
  }
}
