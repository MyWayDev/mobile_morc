import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/models/gift.dart';
import 'package:mor_release/models/gift.order.dart';
import 'package:mor_release/models/gift_pack.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/models/item.order.dart';
import 'package:mor_release/models/lock.dart';
import 'package:mor_release/models/sales.order.dart';

import 'package:scoped_model/scoped_model.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class MainModel extends Model {
  // ** items //** */
  final String _version = '3.0r'; //!Modify for every release version./.
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  int noteCount;
  List<Item> itemData = List();
  List<Item> searchResult = [];
  List<ItemOrder> itemorderlist = [];
  //List<GiftPack> giftpacklist = [];
  List<GiftOrder> giftorderList = [];
  List<PromoOrder> promoOrderList = [];
  String token = '';
  final String firebaseDb = "stage";
  final String stage = "stage";
  final String updateDb = "stage";
  bool loading = false;
  bool isBalanceChecked = true;
  bool isTypeing = false;
  final List<Item> _recoImage = List();

  Item getRecoItem(Item item) {
    // if (searchResult.length == 0 || searchResult.isEmpty) {
    var i = itemData.where((i) => i.itemId == item.itemId).first;
    //int index = itemData.indexOf(i);
    notifyListeners();
    return i;
    // } else {
    //  var i = searchResult.where((i) => i.itemId == item.itemId).first;
    //   int index = searchResult.indexOf(i);
    //    notifyListeners();
    //   return index;
    // }
    //print('getRecoItem index:$index');
  }

  List<Item> getCaouselItems(Item item) {
    _recoImage.clear();
    itemData
        .where((i) =>
            i.itemId != item.itemId &&
            i.brand == item.brand &&
            i.disabled == false &&
            i.imageUrl.length > 10)
        .forEach((i) {
      _recoImage.add(i);
    });
    itemData
        .where((i) =>
            i.itemId != item.itemId &&
            i.grp != null &&
            item.grp != null &&
            i.grp.first == item.grp.first &&
            i.disabled == false &&
            i.imageUrl.length > 10)
        .forEach((i) {
      _recoImage.add(i);
    });
    itemData
        .where((i) =>
            i.itemId != item.itemId &&
            i.cat != null &&
            item.cat != null &&
            i.cat.first == item.cat.first &&
            i.disabled == false &&
            i.imageUrl.length > 10)
        .forEach((i) {
      _recoImage.add(i);
    });

    return _recoImage;
  }

  /*List<String> getRecoImage() {
    _recoImage.clear();

    itemData.forEach((i) => _recoImage.add(i.imageUrl));
    //_recoImage.add(NetworkImage(itemData.first.imageUrl));

    return _recoImage;
  }*/

  /* void fireItemListener(Function onAdded,Function onUpdated){

  }*/
  bool limited(int key) {
    bool islimited = false;
    if (settings.limitedItem != null) {
      for (var l in settings.limitedItem) {
        if (key == l) {
          islimited = true;
        }
      }
    }
    return islimited;
  }

  Future<List<User>> getContacts(String distrId) async {
    List<User> _contactList = await messageKeys(distrId);

    return _contactList;
  }

  Future<List<User>> messageKeys(String distrId) async {
    List<String> keys = [];
    List<User> _contactList = [];
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/production/content/messages/en-US/')
        .once();
    Map<dynamic, dynamic> msg = snapshot.value;
    // print('mkeys:=>${msg.keys}');

    List mkeys = msg.keys.toList();

    for (var k in mkeys) {
      k.split('-')[0] == distrId
          ? keys.add(k.split('-')[1])
          : k.split('-')[1] == distrId ? keys.add(k.split('-')[0]) : print('');
    }
    keys.forEach((k) => k.toString() != null
        ? contact(k.toString()).then((c) {
            _contactList.add((c));
          })
        : null);
    return _contactList;
  }

  Future<User> contact(String key) async {
    User contactUser;
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/production/content/users/en-US/$key')
        .once();
    if (snapshot.value != null) {
      contactUser = User.fromSnapshot(snapshot);
      print(
          'contactUser:${contactUser.key}--${contactUser.name}--${contactUser.photoUrl}');
    }

    return contactUser;
  }

  Lock settings;
//!--------*Settings*-----------//
  Future<Lock> settingsData() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/lockScreen/en-US')
        .once();
    settings = Lock.fromSnapshot(snapshot);
    notifyListeners();

    //print('Setting${settings.bannerUrl}');
    return settings;
  }

  Future<List<Item>> fbItemList() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/stage/content/items/en-US/')
        .once();
    Map<dynamic, dynamic> fbitemsList = snapshot.value;
    List fblist = fbitemsList.values.toList();
    List<Item> fbItems = fblist.map((f) => Item.fromList(f)).toList();
    return fbItems;
  }

  Future<List<Item>> dbItemsList() async {
    List<Item> products;
    //List productlist;
    final response =
        await http.get('http://mywayapi.azurewebsites.net/api/allitemdetails');
    if (response.statusCode == 200) {
      final productlist = json.decode(response.body) as List;

      products = productlist.map((i) => Item.fromJson(i)).toList();
    }
    return products;
  }

  Future<List<Item>> fbItemsUpdateFromDb() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'mobile-coco',
      options: FirebaseOptions(
          googleAppID: '1:592280217867:android:7c1c6ad4297912c3',
          gcmSenderID: '592280217867',
          apiKey: 'AIzaSyDDMUXEZNsB-B2MCw6_xHUA9lirfuYW00w',
          projectID: 'mobile-coco'),
    );

    final List<Item> dbItems = await dbItemsList();
    final List<Item> fbItems = await fbItemList();
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://mobile-coco.appspot.com/');

    final StorageReference storageRef = storage.ref().child('imgs');
    List<Item> items = [];
    for (var i = 0; i < fbItems.length; i++) {
      for (var x = 0; x < dbItems.length; x++) {
        if (fbItems[i].itemId == dbItems[x].itemId) {
          dbItems[x].id = int.parse(fbItems[i].id.toString());
          items.add(dbItems[x]);

          print('count:$i--fbId:${fbItems[i].id} => dbId:${dbItems[x].id}->}');
        }
      }
    }

    for (var i = 0; i < items.length; i++) {
      items[i].catalogue == true
          ? items[i].disabled = false
          : items[i].disabled = true;
      try {
        if (items[i].promo != '0' || items[i].promo != null) {
          var promoString =
              storageRef.child('tag-${items[i].promo}.png').getDownloadURL();
          items[i].promoImageUrl = await promoString;
        } else {
          items[i].promoImageUrl = '';
        }
      } catch (e) {
        // print(e.toString());
      }
      print(
          'count:$i#-fbId:${items[i].id}=>${items[i].itemId}+dbId:${items[i].promo}->PromoUrl:${items[i].promoImageUrl}');
    }

    void updateItemsToFirebase(int id, Item item) {
      DatabaseReference ref = FirebaseDatabase.instance.reference().child(
          'flamelink/environments/stage/content/items/en-US/${id.toString()}');
      ref.update(item.toJsonUpdate());
    }

    for (Item item in items) {
      updateItemsToFirebase(item.id, item);
      print(
          '${item.id}..${item.itemId}..${item.price}..${item.bp}..${item.promo}..${item.promoImageUrl}');
    }
    return items;
  }

  void itemsAndImageAssembly() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'mobile-coco',
      options: FirebaseOptions(
          googleAppID: '1:592280217867:android:7c1c6ad4297912c3',
          gcmSenderID: '592280217867',
          apiKey: 'AIzaSyDDMUXEZNsB-B2MCw6_xHUA9lirfuYW00w',
          projectID: 'mobile-coco'),
    );
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://mobile-coco.appspot.com/');

    StorageReference storageRef;
    storageRef = storage.ref().child('imgs');
    //var spaceRef = storageRef.child('1092.png').getDownloadURL();
//String img = await spaceRef;

    List<Item> items;
    final response =
        await http.get('http://mywayapi.azurewebsites.net/api/allitemdetails');
    if (response.statusCode == 200) {
      List<dynamic> itemlist = json.decode(response.body);
      items = itemlist.map((i) => Item.fromJson(i)).toList();
    }
    print('itemslist length${items.length}');
    for (Item i in items) {
      var imgString = storageRef.child('${i.itemId}.png').getDownloadURL();
      var promoString1 =
          storageRef.child('tag-${i.promo}0.png').getDownloadURL();
      var promoString = storageRef.child('tag-${i.promo}.png').getDownloadURL();

      try {
        i.imageUrl = await imgString;
        i.disabled = false;
        print('${i.itemId}..${i.imageUrl}');
        if (i.promo.length == 1 && i.promo != '0') {
          i.promoImageUrl = await promoString1;
        } else {
          if (i.promo.length == 2)
            i.promoImageUrl = await promoString;
          else {
            i.promoImageUrl = '';
          }
        }
      } catch (e) {
        i.promoImageUrl = '';
        i.imageUrl = '';
        i.disabled = true;
        print('ItemId not AVALABLE');
      }
    }
    /*
*/

    items.forEach((f) =>
        print('${f.itemId}..${f.imageUrl}..${f.disabled}..${f.promoImageUrl}'));
    print('itemslist length${items.length}');

    void pushItemsToFirebase(String itemId, Item item) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('flamelink/environments/stage/content/items/en-US');
      ref.set(item.toJson());
    }

    for (Item item in items) {
      pushItemsToFirebase(item.itemId, item);
      print(
          '${item.itemId}..${item.imageUrl}..${item.disabled}..${item.promoImageUrl}');
    }
  }

  void stageToProduction() async {
    DataSnapshot stagesnapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/items/en-US/')
        .once();

    Map<dynamic, dynamic> itemlist = stagesnapshot.value;
    List list = itemlist.values.toList();
    List<Item> items = list.map((f) => Item.fromList(f)).toList();

    print(items.first.itemId);
//items.forEach((f)=>print({f.itemId:f.key}));

//items.forEach((f)=>print(f.itemId));

    void pushItemsToFirebase(Item item, String key) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('flamelink/environments/$firebaseDb/content/items/en-US/$key');
      //var push =ref.push();
      ref.update({item.id: key});
    }

    for (Item item in items) {
      pushItemsToFirebase(item, item.key);
      print(
          '${item.itemId}..${item.imageUrl}..${item.disabled}..${item.promoImageUrl}');
    }
  }

//!--------*Items*-----------//
  String idPadding(String input) {
    input = input.padLeft(8, '0');
    return input;
  }

//!--------*Orders*---------//
  /* void addItemById(String id, int qty) {
    Item item;

    final ItemOrder itemorder = ItemOrder(
      itemId: item.itemId,
      price: double.parse(item.price.toString()),
      bp: item.bp,
      bv: double.parse(item.bv.toString()),
      qty: qty,
      name: item.name,
      img: item.imageUrl,
    );
  }*/

//!--------*

  void addToItemOrder(Item item, int qty) {
    if (item.bp != 0) {
      giftorderList.clear();
      promoOrderList.clear();
      addItemOrder(item, qty);
    } else {
      addItemOrder(item, qty);
    }
  }

  void addItemOrder(Item item, int qty) {
    final ItemOrder itemorder = ItemOrder(
      itemId: item.itemId,
      price: double.parse(item.price.toString()),
      bp: item.bp,
      bv: double.parse(item.bv.toString()),
      qty: qty,
      name: item.name,
      img: item.imageUrl,
    );
    print('${itemorder.itemId}....${itemorder.qty}');

    var x = itemorderlist.where((orderItem) => orderItem.itemId == item.itemId);
    int i;
    ItemOrder itemOrdered;
    if (x.isNotEmpty) {
      itemOrdered = itemorderlist.where((i) => i.itemId == item.itemId).first;
      i = itemorderlist.indexOf(itemOrdered);
      itemorderlist[i].qty += itemorder.qty;
      notifyListeners();
    } else {
      itemorderlist.add(itemorder);
      notifyListeners();
    }
  }

//!--------*

  int iCount(int x, {String item}) {
    if (item != null) {
      var i = itemData.where((i) => i.itemId == item);
      int index = itemData.indexOf(i.first);

      try {
        var l = itemorderlist.where((o) => o.itemId == itemData[index].itemId);
        // int index = itemorderlist.indexOf(l.first);
        notifyListeners();
        return l.single.qty; //use to be l.first.qty
      } catch (e) {
        notifyListeners();

        return 0;
      }
    }
    if (itemorderlist.length > 0) {
      if (searchResult.length == 0) {
        try {
          var l = itemorderlist.where((o) => o.itemId == itemData[x].itemId);
          //int index = itemorderlist.indexOf(l.first);
          notifyListeners();
          return l.single.qty; //use to be l.first.qty
        } catch (e) {
          notifyListeners();
          return 0;
        }
      } else {
        try {
          var l =
              itemorderlist.where((o) => o.itemId == searchResult[x].itemId);
          // int index = itemorderlist.indexOf(l.first);
          notifyListeners();
          return l.single.qty; //use to be l.first.qty
        } catch (e) {
          notifyListeners();

          return 0;
        }
      }
    }
    return 0;
  }

//!--------*

  int getItemIndex(int x) {
    var item = itemData.where((i) => i.itemId == itemorderlist[x].itemId);
    int index = itemData.indexOf(item.first);

    return index;
  }

  int getIndex(String i) {
    var item = itemData.where((t) => t.itemId == i);
    int index = itemData.indexOf(item.first);
    //print('getIndex:$index');
    //print('${itemData.length}');
    return index;
  }

//!--------*
  void deleteItemOrder(int i) {
    giftorderList.clear();
    promoOrderList.clear();
    itemorderlist.remove(itemorderlist[i]);
    notifyListeners();
  }

//!--------*
  void removeItemOrder(Item item, int qty) {
    giftorderList.clear();
    promoOrderList.clear();
    final ItemOrder itemorder = ItemOrder(
        itemId: item.itemId,
        price: double.parse(item.price.toString()),
        bp: item.bp,
        bv: double.parse(item.bv.toString()),
        qty: qty);

    var x = itemorderlist.where((orderItem) => orderItem.itemId == item.itemId);
    int i;
    bool canRemove = false;
    x.forEach((f) => f.qty >= qty ? canRemove = true : canRemove = false);
    ItemOrder itemOrdered;

    if (x.isNotEmpty && canRemove) {
      itemOrdered = itemorderlist.where((i) => i.itemId == item.itemId).first;
      i = itemorderlist.indexOf(itemOrdered);
      if (itemOrdered.qty == itemorder.qty) {
        itemorderlist.remove(itemOrdered);
      } else {
        itemorderlist[i].qty -= itemorder.qty;
        notifyListeners();
        print('olderIndex:$i');
        print('x not empty :${x.isNotEmpty}');
      }
    }
  }

//!--------*
  List<ItemOrder> get displayItemOrder {
    return List.from(itemorderlist);
  }

  /*List<GiftPack> get displayGiftOrder {
    return List.from(giftpacklist);
  }*/

//!--------*
  double orderSum() {
    double x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.price * i.qty;
    }
    notifyListeners();
    return x;
  }

//!--------*
  int orderBp() {
    int x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.bp * i.qty;
    }
    notifyListeners();
    return x;
  }

//!--------*
  int itemCount() {
    int x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.qty;
    }
    // print('itemCount:$x');
    notifyListeners();
    return x;
  }

//!--------*legacy salesOrder*---------//

  String distrIdDel;
  String docIdDel;
  bool loadingSoPage = false;
  Future<List<Sorder>> checkSoDeletion(String userId) async {
    List<Sorder> sos;
    final http.Response response = await http
        .get('http://mywayapi.azurewebsites.net/api/userpending/$userId');
    if (response.statusCode == 200) {
      print('check deletion!!');
      List<dynamic> soList = json.decode(response.body);
      sos = soList.map((i) => Sorder.fromJson(i)).toList();
    }
    return sos;
  }

  void checkSoDupl(
    Function getSorders,
    String userId,
  ) async {
    List<Sorder> _check = await checkSoDeletion(userId);
    int _recheck = _check
        .where((f) => f.distrId == distrIdDel && f.docId == docIdDel)
        .length;
    if (_recheck == 0) {
      getSorders(userId);
      loadingSoPage = false;
    } else {
      checkSoDupl(getSorders, userId);
      //print(_recheck);
    }
  }

  Future<DateTime> serverTimeNow() async {
    DateTime _stn;
    final http.Response response =
        await http.get('http://mywayapi.azurewebsites.net/api/datetimenow');
    if (response.statusCode == 200) {
      String stn = json.encode(response.body);
      // print(stn);
      String subTime = stn.substring(3, 22);
      // print(subTime);
      _stn = DateTime.parse(subTime);
    }
    // print("serverTime:$_stn");
    return _stn;
  }

//!--------*Gift*---------//
  int gCount(int x) {
    var g = giftorderList[x].qty;
    return g;
  }

  int promoCount(int x) {
    var p = promoOrderList[x].qty;
    return p;
  }

  int giftBp() {
    int x = 0;
    for (GiftOrder i in giftorderList) {
      x += i.bp * i.qty;
    }
    notifyListeners();
    return x;
  }

  int promoBp() {
    int x = 0;
    for (PromoOrder i in promoOrderList) {
      x += i.bp * i.qty;
    }
    notifyListeners();
    return x;
  }

  void addGiftPackOrder(GiftPack pack) {
    final GiftOrder giftOrder = GiftOrder(
      pack: pack.pack,
      bp: pack.bp,
      qty: pack.qty,
      imageUrl: pack.imageUrl,
      desc: pack.desc,
    );
    var x = giftorderList.where((i) => i.bp == pack.bp);
    int i;
    GiftOrder giftOrdered;
    if (x.isNotEmpty) {
      giftOrdered = giftorderList.where((i) => i.bp == pack.bp).first;
      i = giftorderList.indexOf(giftOrdered);
      giftorderList[i].qty += giftOrder.qty;
      notifyListeners();
      print('giftorderlist:${giftorderList.length}');
    } else {
      giftorderList.add(giftOrder);
      notifyListeners();
      print('giftorderlist:${giftorderList.length}');
    }
  }

  void addPromoPackOrder(PromoPack pack) {
    final PromoOrder promoOrder = PromoOrder(
      promoPack: pack.promoPack,
      bp: pack.bp,
      qty: pack.qty,
      imageUrl: pack.imageUrl,
      desc: pack.desc,
    );
    var x = promoOrderList.where((i) => i.bp == pack.bp);
    int i;
    PromoOrder promoOrdered;
    if (x.isNotEmpty) {
      promoOrdered = promoOrderList.where((i) => i.bp == pack.bp).first;
      i = promoOrderList.indexOf(promoOrdered);
      promoOrderList[i].qty += promoOrder.qty;
      notifyListeners();
    } else {
      promoOrderList.add(promoOrder);
      notifyListeners();
    }
  }

  void deleteGiftOrder(int i) {
    giftorderList.remove(giftorderList[i]);
    notifyListeners();
  }

  void deletePromoOrder(int i) {
    promoOrderList.remove(promoOrderList[i]);
    notifyListeners();
  }

  Future<List<Gift>> giftList() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/gifts/en-US/')
        .once();

    Map<dynamic, dynamic> giftsList = snapshot.value;
    List list = giftsList.values.toList();
    List<Gift> gifts = list.map((f) => Gift.fbList(f)).toList();

    return gifts;
  }

  Future<List<Promo>> promoList() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/timePromo/en-US/')
        .once();

    Map<dynamic, dynamic> promosList = snapshot.value;
    List list = [];
    if (snapshot.value != null) {
      list = promosList.values.toList();
    } else {
      list = [];
    }

    List<Promo> promos = [];
    promos = list.map((f) => Promo.fbList(f)).toList();
    //bool activePromo = promoIsActive(promos);
    //print('Is Active Promo : => $activePromo');
    DateTime serverTime;
    Duration promoFrom;
    Duration promoTo;

    List<Promo> promosOngoing = [];
    serverTime = await serverTimeNow();

    for (var x in promos) {
      var serverT = DateFormat('yyyy-MM-dd').format(serverTime);

      var promoF = DateFormat('yyyy-MM-dd').format(DateTime.parse(x.fromDate));
      var promoT = DateFormat('yyyy-MM-dd').format(DateTime.parse(x.toDate));
      promoFrom = DateTime.parse(promoF).difference(DateTime.parse(serverT));
      promoTo = DateTime.parse(promoT).difference(DateTime.parse(serverT));
      if (promoFrom.inDays <= 0 && promoTo.inDays >= 0) {
        // print('Fromdays:${promoFrom.inDays}ToDays:${promoTo.inDays}');
        promosOngoing.add(x);
      }
      //  print('Fromdays:${promoFrom.inDays}ToDays:${promoTo.inDays}');
    }
    return promosOngoing ?? [];
  }

  List<Gift> giftQty;
  Future<void> checkGift(int orderbp, int giftbp) async {
    int _qualifyBp = orderbp - giftbp;
    List<Gift> gifts = [];
    gifts = await giftList();

    List<Gift> aprovedGift = [];
    giftQty = [];
    gifts.forEach((g) => _qualifyBp / g.bp >= 1 ? aprovedGift.add(g) : null);

//gifts.forEach((g)=>qualifyBp/g.bp>=1?aprovedGift.add(g):null);

    for (var i = 0; i < aprovedGift.length; i++) {
      double x = _qualifyBp / aprovedGift[i].bp;
      for (var e = 0; e < x.toInt(); e++) {
        giftQty.add(aprovedGift[i]);
      }
    }
  }

  List<Promo> promoQty;
  Future<void> checkPromo(int orderbp, int promobp) async {
    int _qualifyBp = orderbp - promobp;
    List<Promo> promos = [];
    promos = await promoList();

    List<Promo> aprovedPromo = [];
    promoQty = [];
    if (promos.length >= 1) {
      promos
          .forEach((p) => _qualifyBp / p.bp >= 1 ? aprovedPromo.add(p) : null);
      for (var i = 0; i < aprovedPromo.length; i++) {
        double x = _qualifyBp / aprovedPromo[i].bp;
        for (var e = 0; e < x.toInt(); e++) {
          promoQty.add(aprovedPromo[i]);
        }
      }
    }
    //print('promos length==>${promos.length}');
  }

  bool isloading = false;
  void loadGift(List<GiftPack> giftData, int index) {
    isloading = true;
    Duration wait = Duration(milliseconds: 800);
    Timer(wait, () async {
      addGiftPackOrder(giftData[index]);
      await checkGift(orderBp(), giftBp());
      getGiftPack();
      isloading = false;
    });
  }

  void loadPromo(List<PromoPack> promoData, int index) {
    isloading = true;
    Duration wait = Duration(milliseconds: 800);
    Timer(wait, () async {
      addPromoPackOrder(promoData[index]);
      await checkPromo(orderBp(), promoBp());
      getPromoPack();
      isloading = false;
    });
  }

  void rungiftState() {
    giftState();
    promoState();
  }

  void giftState() async {
    await checkGift(orderBp(), giftBp());
    getGiftPack();
  }

  void promoState() async {
    await checkPromo(orderBp(), promoBp());
    getPromoPack();
  }

  List<GiftPack> giftPacks = [];
  void getGiftPack() {
    // List<Item> giftItems =List() ;
    Item item;
    giftPacks.clear();
    GiftPack giftPack;
//print('GiftPack:${giftQty.length}');
    for (var i = 0; i < giftQty.length; i++) {
      giftPack = GiftPack(
          key: i.toString(),
          bp: giftQty[i].bp,
          imageUrl: giftQty[i].imageUrl,
          desc: giftQty[i].desc);
      giftPack.pack = [];

      for (var p = 0; p < giftQty[i].items.length; p++) {
        item = itemData
            .where((item) => item.key == giftQty[i].items[p].toString())
            .first;
        //print('${item.itemId}');

        giftPack.pack.add(item);
        //giftPacks.add(giftPack);

      }
      giftPacks.add(giftPack);

      // giftItems.forEach((f)=>print(f.itemId));
    }
    //  giftPacks.forEach((f)=>print(f.bp));
    //  giftPacks.forEach((f)=>f.pack.forEach((p)=>print({p.itemId:p.image})));

    //*----------\\\\//////////////////////////***////////////////////////////\\\\-----------*//

    //print('PackKey:${giftPack.key} + PackKey:${giftPack.bp}'  );
    //print('${giftPack.pack.length}');
    //giftPack.pack.forEach((f)=>print({f.itemId:f.price}));
    //print('giftPacks Length:${giftPacks.length}');
    // return giftPacks;
  }

  List<PromoPack> promoPacks = [];
  void getPromoPack() {
    Item item;
    promoPacks.clear();
    PromoPack promoPack;
    for (var i = 0; i < promoQty.length; i++) {
      promoPack = PromoPack(
          key: i.toString(),
          bp: promoQty[i].bp,
          imageUrl: promoQty[i].imageUrl,
          desc: promoQty[i].desc);
      promoPack.promoPack = [];
      for (var p = 0; p < promoQty[i].items.length; p++) {
        item = itemData
            .where((item) => item.key == promoQty[i].items[p].toString())
            .first;
        //print('${item.itemId}');

        promoPack.promoPack.add(item);
      }
      promoPacks.add(promoPack);
    }
  }

//!--------*Stock*---------//
  Future<int> getStock(String itemId) async {
    http.Response response =
        await http.get('http://mywayapi.azurewebsites.net/api/stock/$itemId');

    List stockData = json.decode(response.body);
    ItemOrder itemOrder = ItemOrder.fromJson(stockData[0]);
//ItemOrder itemOrder= ItemOrder.fromJson(json.decode(response.body));

    print(itemOrder.qty);
    return itemOrder.qty;
  }

  int getItemOrderQty(Item item) {
    int x;
    bool y = itemorderlist.where((i) => i.itemId == item.itemId).isNotEmpty;
    if (y) {
      x = itemorderlist.where((i) => i.itemId == item.itemId).first.qty;
      print("itemId${item.itemId}: qty:$x");
    } else {
      x = 0;
    }
    return x;
  }

  void addCatToOrder(String itemid) {
    final Item item = Item(
      itemId: itemid,
      price: 0,
      bp: 0,
      bv: 0.0,
      name: 'كتالوج شهر',
      imageUrl: '',
    );
    addToItemOrder(item, 2);
  }

  void addAdminToOrder(String itemid) {
    final Item item = Item(
      itemId: itemid,
      price: settings.adminFee,
      bp: 0,
      bv: 0.0,
      name: 'مصاريف إدارية"',
      imageUrl: '',
    );
    addToItemOrder(item, 1);
  }

  void addCourierToOrder(String itemid, int fee) {
    final Item item = Item(
      itemId: itemid,
      price: fee,
      bp: 0,
      bv: 0.0,
      name: 'مصاريف إدارية"',
      imageUrl: '',
    );
    addToItemOrder(item, 1);
  }

  void mockOrder(Item item, int qty) {
    addItemOrder(item, qty);
  }

  Future<OrderMsg> orderBalanceCheck(String shipmentId, int courierfee,
      String distrId, String note, String areaId) async {
    OrderMsg msg;
    List<ItemOrder> orderOutList = List();
    print(itemorderlist.length);
    //promoOrderList.forEach((p) => print('bp:${p.bp}Qty:${p.qty}'));
    for (ItemOrder item in itemorderlist) {
      await getStock(item.itemId).then((i) {
        if (i < item.qty) {
          orderOutList.add(item);
          orderOutList.last.qty = i;
          print('OutListBelow:');
          isBalanceChecked = false;
          print({orderOutList.last.itemId: orderOutList.last.qty});
        }
      });
    }
    if (orderOutList.length > 0) {
      for (ItemOrder item in orderOutList) {
        itemorderlist
            .where((i) => i.itemId == item.itemId)
            .forEach((f) => f.qty = item.qty);
      }
      orderOutList.clear();
      giftorderList.clear();
      promoOrderList.clear();
      itemorderlist.removeWhere((i) => i.qty <= 0);
      isBalanceChecked = false;
    } else {
      isBalanceChecked = true;
      msg = await saveOrder(shipmentId, courierfee, distrId, note, areaId);
    }
    return msg;
//itemorderlist.where((i)=>i.qty==0).forEach((f)=>itemorderlist.remove(f));
//print(itemorderlist.length);
//itemorderlist.forEach((f)=>print('ItemId:${f.itemId}new Qty:${f.qty}'));
  }

  bool _isWaiting = true;
  bool wait() {
    Duration wait = Duration(minutes: 1);
    Timer(wait, () async {
      print('waiting...');
    });
    _isWaiting = false;
    return _isWaiting;
  }

//!-------------------------------------SaveOrder---------------------------------//

  Future<OrderMsg> saveOrder(String shipmentId, int courierfee, String distrId,
      String note, String areaId) async {
    //itemorderlist.forEach((i)=>print({i.itemId:i.qty}));
// giftorderList.forEach((p)=>print(p.pack.map((g)=>{g.itemId:p.qty})));
    print('OrderListLength:${itemorderlist.length}');

    addCatToOrder(settings.catCode);
    addAdminToOrder('91');
    if (courierfee > 0) {
      addCourierToOrder('90', courierfee);
    }
    giftorderList.forEach((g) => g.pack.forEach((p) => {p.bp = 0: p.bv = 0.0}));
    promoOrderList
        .forEach((p) => p.promoPack.forEach((pp) => {pp.bp = 0: pp.bv = 0.0}));
    giftorderList.forEach((g) => g.pack.forEach((p) => p.price = 0.0));
    promoOrderList.forEach((p) => p.promoPack.forEach((pp) => pp.price = 0.0));

    giftorderList
        .forEach((g) => g.pack.forEach((p) => addToItemOrder(p, g.qty)));
    promoOrderList
        .forEach((p) => p.promoPack.forEach((pp) => addToItemOrder(pp, p.qty)));

    SalesOrder salesOrder = SalesOrder(
      distrId: distrId,
      userId: userInfo.distrId,
      total: orderSum(),
      totalBp: orderBp(),
      note: note,
      courierId: shipmentId,
      areaId: idPadding(areaId),
      order: itemorderlist,
    );

    print(salesOrder.postOrderToJson(salesOrder));

    Response response = await salesOrder.createPost(salesOrder);

    if (response.statusCode == 201) {
      print('Order Msg:${response.body}!!');
      itemorderlist.clear();
      giftorderList.clear();
      promoOrderList.clear();

      OrderMsg msg = OrderMsg.fromJson(json.decode(response.body));

      return msg;
    } else {
      OrderMsg errorMsg = OrderMsg(error: 'operation failed');
      return errorMsg;
    }

//return salesOrder;
//itemorderlist.forEach((f)=>so.order.add(f))  ;
//itemorderlist.forEach((f)=>so.order.add(f));
//print('SalesOrderLength:${so.order.length}');
//salesOrder.order.forEach((o)=>print(postSalesOrderToJson(SSo)));
  }

//!--------*Areas*---------////
//**working here */
//? Areaupdate to firebase..

  List<Area> areas;

  Future<List<Area>> getArea() async {
    final response =
        await http.get('http://mywayapi.azurewebsites.net/api/areas');

    if (response.statusCode == 200) {
      //Map<String,dynamic> jSON;
// List<Area> _areas = List();
      List<dynamic> responseList = json.decode(response.body);
      areas = responseList.map((l) => Area.fromJson(l)).toList();
      areas.forEach((f) => print({f.areaId: f.name}));
    }
    return areas;
/*
  void areaPushToFirebase(String areaId,Area area){
  DatabaseReference ref = FirebaseDatabase.instance.reference()
  .child('flamelink/environments/production/content/areas/en-US');
  ref.child(areaId).set(area.toJson());
}
for(var area in areas){
  areaPushToFirebase(area.areaId, area);
  print('setting...${area.areaId}..${area.name}');
}*/
  }

//!--------*Courier*----------//

  List<Courier> couriers;

  void getShipmentCompanies() async {
    final response = await http
        .get('http://mywayapi.azurewebsites.net/api/shipmentcompanies');

    void shipmentPushToFirebase(String courierId, Courier courier) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('flamelink/environments/$firebaseDb/content/courier/en-US');
      ref.child(courierId).update(courier.toJson());
    }

    if (response.statusCode == 200) {
      List<dynamic> responseList = json.decode(response.body);
      couriers = responseList.map((l) => Courier.fromJson(l)).toList();
    }
    for (var c in couriers) {
      shipmentPushToFirebase(c.courierId, c);
    }
//return couriers;
  }

  List companies;
  Future<List> courierList(String areaid) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            'flamelink/environments/$firebaseDb/content/courier/en-US/') //!enviroments/$firebaseDb
        .once();

    List courierList = snapshot.value;

    List ships = [];
    for (var c in courierList) {
      if (c != null) {
        for (var s in c['service']) {
          for (var a in s['areas']) {
            if (a.toString() == areaid) {
              // print(c['courierId']);
              ships.add(c);
            }
          }
        }
      }
    }
    List companies = ships.map((f) => Courier.fromList(f)).toList();
    // companies.forEach((c) => print(c));
//companies.forEach((f)=>print('${f.name} : ${f.courierId}'));

    return companies;
  }

  /*
  Future<List> courierList(String areaid) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            'flamelink/environments/production/content/courier/en-US/') //!enviroments/$firebaseDb
        .once();
    Map<dynamic, dynamic> courier = snapshot.value;
    List courierList = courier.values.toList();

    List ships = [];
    for (var c in courierList) {
      for (var s in c['service']) {
        for (var a in s['areas']) {
          if (a.toString() == areaid) {
            // print(c['courierId']);
            ships.add(c);
          }
        }
      }
    }
    List companies = ships.map((f) => Courier.fromList(f)).toList();
    companies.forEach((c) => print(c));
//companies.forEach((f)=>print('${f.name} : ${f.courierId}'));

    return companies;
  }*/

//!--------*
  Future<bool> courierService(String courierId, String areaId) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            'flamelink/environments/$firebaseDb/content/courier/en-US/$courierId/service') //!enviroments/production
        .once();
    List list = snapshot.value;
// print(list.length);
    List<Service> services = list.map((f) => Service.fromJson(f)).toList();
//print(services.map((f)=>f.areas.forEach((a)=>a == areaId))) ;
    bool x;
    for (var s in services) {
      for (var a in s.areas) {
        if (areaId == a.toString()) {
          x = true;
        } else {
          x = false;
        }
      }
    }
    return x;
  }

  Future<int> courierServiceFee(
      String courierId, String areaId, int orderBp) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            'flamelink/environments/$firebaseDb/content/courier/en-US/$courierId/service') //!enviroments/production
        .once();
    List list = snapshot.value;
// print(list.length);
    List<Service> services = list.map((f) => Service.fromJson(f)).toList();
//print(services.map((f)=>f.areas.forEach((a)=>a == areaId))) ;
    int x;
    for (var s in services) {
      for (var a in s.areas) {
        if (areaId == a.toString()) {
          if (orderBp <= s.freeBp || s.freeBp == 0) {
            x = s.fees;
          } else {
            x = 0;
          }
        }
      }
    }
    return x;
  }

  //print(services.map((f)=> f.areas.map((a)=>a.toString() == areaId)));
//Service service = Service.fromJson(list.first);
//print(service.fees);
  //list.forEach((f)=>Service.fromJson(f));
//List<Service> service = Service.fromSnapshot(snapshot);
//print(service.fees);
  /*_list.length;
for( var i = 0 ; i < _list.length; i++){

}*/

//!--------*Users/Members*-----------//
  void userPushToFirebase(String id, User user) {
    String memberId = int.parse(id).toString();
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/users/en-US');
    ref.child(memberId).set(user.toJson());
  }

  User memberData;
  //!--------*
  Future<User> memberJson(String distrid) async {
    http.Response response = await http
        .get('http://mywayapi.azurewebsites.net/api/memberid/$distrid');

    if (response.body.length > 2) {
      List responseData = await json.decode(response.body);
      memberData = User.formJson(responseData[0]);
    } else {
      return memberData = null;
    }

    return memberData;
    /*(
      distrId: responseData[0]['DISTR_ID'],
      name: responseData[0]['ANAME'],
      distrIdent: responseData[0]['DISTR_IDENT'],
      email: responseData[0]['E_MAIL'],
      phone: responseData[0]['TELEPHONE'],
    );*/
  }

  User nodeJsonData;
  Future<User> nodeJson(String nodeid) async {
    http.Response response = await http
        .get('http://mywayapi.azurewebsites.net/api/memberid/$nodeid');

    if (response.statusCode == 200) {
      List responseData = await json.decode(response.body);
      nodeJsonData = User.formJson(responseData[0]);
    } else {
      return nodeJsonData = null;
    }
    print('nodeJsonArea:${nodeJsonData.areaId}');
    return nodeJsonData;
  }

//!--------*
  Future<String> regUser(String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    // print(user.uid);

    return user.uid;
  }
// bool isLoggedIn;
  /// bool isValid;

//!------------*

  User user;
  Future<User> userData(String key) async {
    print('userData key:$key');
    final DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/users/en-US')
        .child(key)
        .once();
    user = User.fromSnapshot(snapshot);
    print('userData user.distrId:${user.distrId}');
    print('userData user.token:${user.token}');
    return user;
  }

//!--------*
  FirebaseUser _user;
  Future<bool> logIn(String key, String password, BuildContext context) async {
    print('key:$key');
    User _userInfo = await userData(key)
        .catchError((e) => print('ShitTY Erro:${e.toString()}'));
    if (_userInfo != null) {
      if (_userInfo.isAllowed) {
        print('user is allowed ${_userInfo.isAllowed.toString()}');
        versionControl(context);
        locKCart(context); //! uncomment this before buildR
        locKApp(context); //! uncomment this before buildR
        userAccess(key, context);
        // getArea();

        try {
          _user = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _userInfo.email, password: password);
        } catch (e) {
          print('singin error caught:${e.toString()}');
          return false;
        }
        updateToke(key);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  updateToke(String _key) {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/$firebaseDb/content/users/en-US/$_key');
    if (token != null) {
      ref.update({"token": token});
    }
  }

  //!--------*
  bool access = true;
  void userAccess(key, BuildContext context) {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference databaseReference;
    databaseReference = database
        .reference()
        .child('flamelink/environments/$firebaseDb/content/users/en-US/$key/');
    databaseReference.onValue.listen((event) async {
      access = await setIsAllowed(User.fromSnapshot(event.snapshot).isAllowed);
      print('isAllowedxx:$access');
      if (!access) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        /* Navigator.pop(context,
                          MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()));*/
      }
    });

    // return _access;
  }

  bool cartLocked = false;
  void locKCart(BuildContext context) {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference databaseReference;
    databaseReference = database.reference().child(
        'flamelink/environments/$firebaseDb/content/lockScreen/en-US/lockCart');
    databaseReference.onValue.listen((event) async {
      cartLocked = await event.snapshot.value;
      //print('CARTLOCKED-XXXXX:$cartLocked');
      if (cartLocked) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        //signOut();
        //Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

        /* Navigator.pop(context,
                          MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()));*/
      }
    });

    // return _access;
  }

  bool appLocked = false;
  void locKApp(BuildContext context) {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference databaseReference;
    databaseReference = database.reference().child(
        'flamelink/environments/$firebaseDb/content/lockScreen/en-US/lockApp');
    databaseReference.onValue.listen((event) async {
      appLocked = await event.snapshot.value;
      //print('APPLOCKED-XXXXX:$appLocked');
      if (appLocked) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

        /* Navigator.pop(context,
                          MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()));*/
      }
    });

    // return _access;
  }

  void versionControl(BuildContext context) {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference databaseReference;
    databaseReference = database.reference().child(
        'flamelink/environments/$firebaseDb/content/lockScreen/en-US/version');
    databaseReference.onValue.listen((event) async {
      String version = await event.snapshot.value;
      //print('APPLOCKED-XXXXX:$appLocked');
      if (version != _version) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        print('$version CheckYour Version $_version :)');
        signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }

      /* Navigator.pop(context,
                          MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()));*/
    });

    // return _access;
  }
  //!--------*

  Future<bool> leaderVerification(String distrId) async {
    String v;

    http.Response response = await http.get(
        'http://mywayapi.azurewebsites.net/api/leaderverification/${userInfo.distrId}/$distrId');

    if (response.statusCode == 200) {
      List vList = await json.decode(response.body);
      print('verList:${vList.length}');

      if (vList.length == 1) {
        v = vList[0].toString().toLowerCase();
      } else {
        v = 'false';
      }
    }
    bool b;
    v == 'true' ? b = true : b = false;
    print('verification:$b');
    return b;
  }

  //!--------*
  User userInfo;
  void userDetails() {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference databaseReference;
    databaseReference = database.reference().child(
        'flamelink/environments/$firebaseDb/content/users/en-US/${user.key}/');
    databaseReference.onValue.listen((event) async {
      userInfo = User.fromSnapshot(event.snapshot);
    });
  }

  //!--------*
  Future<bool> setIsAllowed(bool allowed) async {
    final User userAccess = User(isAllowed: allowed);
    return userAccess.isAllowed;
  }

  //!--------*
  Future<bool> formEntry(bool validate, Future<bool> signin) async {
    bool isLoggedIn = await signin;
    bool isValid = validate;

    if (isValid) {
      if (isLoggedIn && loggedUser() != null) {
        print('isLoggedIn:$isLoggedIn');
        print('isValidIn:$isValid');

        return true;
      } else {
        return false;
      }
    } else {
      print('isLoggedIn:$isLoggedIn');
      print('isValidIn:$isValid');
      return false;
    }
  }

//!--------*
  Future<bool> emailSignIn(String email, String password) async {
    try {
      _user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print(' Future signIn display ${_user.uid}');
    } catch (e) {
      print('singin error caught:${e.toString()}');
      return false;
    }
    return true;
  }

//!--------*
  Future<void> signOut() async {
    print('signing outttttttttt');

    return FirebaseAuth.instance.signOut();
  }

  Future<String> loggedUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.email;
  }
}

/* //! 
void main() async {
  List _data = await getJson();

  for (int i = 0; i < _data.length; i++) {}

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('JSON PARSE'),
        centerTitle: true,
        backgroundColor: Colors.pink[900],
      ),
      body: ListView.builder(
        itemCount: _data.length,
        padding: EdgeInsets.all(15.0),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(_data[index]['ITEM_ID']),
                  Text(_data[index]['ANAME']),
                ],
              )
            ],
          );
        },
      ),
    ),
  ));
}

Future<List> getJson() async {
  String apiUrl = 'http://mywayapi.azurewebsites.net/api/allitemdetails';

  http.Response response = await http.get(apiUrl);

  return json.decode(response.body);
}

*/
