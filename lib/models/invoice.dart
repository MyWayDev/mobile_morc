class InvoiceItem {
  String docId;
  String itemId;
  String itemName;
  var total;
  var itemBp;
  var totalBp;
  var price;
  var qty;

  InvoiceItem(
      {this.docId,
      this.itemId,
      this.itemName,
      this.total,
      this.itemBp,
      this.totalBp,
      this.price,
      this.qty});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
        docId: json['DOC_ID'],
        itemId: json['ITEM_ID'],
        itemName: json['ITEM_NAME'],
        total: json['NET_TOTAL'],
        itemBp: json['ITEM_BP'],
        totalBp: json['TOTAL_BP'],
        price: json['PRICE'],
        qty: json['QTY']);
  }
}

class Invoice {
  String docId;
  String docDate;
  String distrId;
  String distrName;
  String shipId;
  String status;
  String dlvDate;
  String shipper;
  String counter;
  List<InvoiceItem> invoiceItems;

  double get invocieTotal {
    double _totalPrice = 0;
    for (InvoiceItem i in invoiceItems) {
      _totalPrice += i.total;
    }
    return _totalPrice;
  }

  double get invocieBp {
    double _totalBp = 0;
    for (InvoiceItem i in invoiceItems) {
      _totalBp += i.totalBp;
    }
    return _totalBp;
  }

  Invoice(
      {this.docId,
      this.docDate,
      this.distrId,
      this.distrName,
      this.shipId,
      this.status,
      this.dlvDate,
      this.shipper,
      this.counter,
      this.invoiceItems});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
        docId: json['DOC_ID'],
        docDate: json['DOC_DATE'],
        distrId: json['DISTR'],
        distrName: json['DISTR_NAME'],
        shipId: json['DS_SHIPMENT'],
        status: json['SHIPMENT_STATUS'],
        shipper: json['COMP_NAME'],
        dlvDate: json['DLV_DATE'],
        counter: json['COUNTER']);
  }
}
