class Sorder {
  String docId;
  String distrId;
  String distrName;
  String counter;
  String docDate;
  String addTime;
  List<SoItem> soItems;

  String get soTotal {
    double _totalPrice = 0;
    for (SoItem s in soItems) {
      _totalPrice += s.total;
    }
    return _totalPrice.toString();
  }

  String get soBp {
    double _soBp = 0;
    for (SoItem s in soItems) {
      _soBp += s.totalBp;
    }
    return _soBp.toString();
  }

  DateTime get addDate {
    DateTime _addDate = DateTime.parse(docDate + " " + addTime);
    return _addDate;
  }

  Sorder({
    this.docId,
    this.docDate,
    this.addTime,
    this.distrId,
    this.distrName,
    this.counter,
    this.soItems,
  });
  factory Sorder.fromJson(Map<String, dynamic> json) {
    return Sorder(
      docId: json['DOC_ID'],
      docDate: json['DOC_DATE'],
      distrId: json['DISTR_ID'],
      distrName: json['DISTRNAME'],
      addTime: json['ADD_TIME'],
      counter: json['COUNTER'],
    );
  }
}

class SoItem {
  String docId;
  String itemId;
  String itemName;
  var qty;
  var price;
  var total;
  var itemBp;
  var totalBp;

  SoItem({
    this.docId,
    this.itemId,
    this.itemName,
    this.qty,
    this.price,
    this.total,
    this.itemBp,
    this.totalBp,
  });

  factory SoItem.fromJson(Map<String, dynamic> json) {
    return SoItem(
      docId: json['DOC_ID'],
      itemId: json['ITEM_ID'],
      itemName: json['ITEMNAME'],
      qty: json['QTY_REQ'],
      price: json['UNIT_PRICE'],
      total: json['TOT_PRICE'],
      itemBp: json['ITEM_BP'],
      totalBp: json['TOTAL_BP'],
    );
  }
}
