import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ItemOrder {
  String itemId;
  double price;
  int bp;
  double bv;
  int qty;
  String name;
  String img;

  double get totalPrice {
    double _totalPrice = qty * price;
    return _totalPrice;
  }

  int get totalBp {
    int _totalBp = qty * bp;
    return _totalBp;
  }

  ItemOrder({
    this.itemId,
    this.price,
    this.qty,
    this.bp,
    this.bv,
    this.name,
    this.img,
  });

  Map<String, dynamic> toJson() => {
        "ITEM_ID": itemId,
        "QTY": qty,
        "QTY_REQ": qty,
        "UNIT_PRICE": price,
        "NET_PRICE": totalPrice,
        "TOT_PRICE": totalPrice,
        "ITEM_BP": bp,
        "ITEM_BV": bv,
      };

  String postToJson(ItemOrder itemOrder) {
    final dyn = itemOrder.toJson();
    return json.encode(dyn);
  }

  factory ItemOrder.fromJson(Map<String, dynamic> json) {
    return ItemOrder(itemId: json['itemId'], qty: json['qty']);
  }

  //  this.bv, });
}

class OrderMsg {
  String soid;
  double amt;
  String docDate;
  String addTime;
  String error;

  DateTime get addDate {
    DateTime _addDate = DateTime.parse(docDate + " " + addTime);
    return _addDate;
  }

  OrderMsg({this.soid, this.amt, this.docDate, this.addTime, this.error});
  factory OrderMsg.fromJson(Map<String, dynamic> msg) {
    return OrderMsg(
      soid: msg['id'],
      amt: msg['amt'],
      docDate: msg['docDate'],
      addTime: msg['addTime'],
    );
  }
}

class SalesOrder {
  String distrId;
  String userId;
  String courierId;
  String areaId;
  double total;
  int totalBp;
  String note;
  String amt;
  String so;
  List<ItemOrder> order;

  SalesOrder(
      {this.distrId,
      this.userId,
      this.total,
      this.totalBp,
      this.order,
      this.courierId,
      this.areaId,
      this.note,
      this.amt,
      this.so});

  Map<String, dynamic> toJson() => {
        "a9master": {
          "CUS_VEN_ID": distrId,
          "USER_ID": userId,
        },
        "apmaster": {
          "GROSS_TOTAL": total,
          "NET_TOTAL": total,
          "DS_SHIPMENT_COMP": courierId,
          "DS_SHIPMENT_PLACE": areaId,
          "AREMARKS": note,
        },
        "aadetail": order,
        "aqdetail": order,
      };

  String postOrderToJson(SalesOrder salesOrder) {
    final dyn = salesOrder.toJson();
    return json.encode(dyn);
  }

  Future<http.Response> createPost(SalesOrder salesOrder) async {
    final response =
        await http.put('http://mywayapi.azurewebsites.net/api/invoice',
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              //HttpHeaders.authorizationHeader: ''
            },
            body: postOrderToJson(salesOrder));
    return response;
  }
}
