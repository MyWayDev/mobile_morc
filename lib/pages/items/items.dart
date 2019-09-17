import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/models/lock.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../models/item.dart';
import '../items/item.card.dart';
import 'package:mor_release/scoped/connected.dart';

class ItemsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ItemsPage();
  }
}

@override
class _ItemsPage extends State<ItemsPage> {
  //String db = 'production';
  String path =
      "flamelink/environments/production/content/items/en-US"; //! VERY IMPORTANT change back to production before release
  List<Item> itemData = List();
  List<Item> searchResult = [];
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  var subAdd;
  var subChanged;

  TextEditingController controller = new TextEditingController();
  Lock lock;
  //bool defaultDB = true;

  @override
  void initState() {
    super.initState();
    databaseReference = database.reference().child(path);
    Query query = databaseReference.orderByChild('catalogue').equalTo(true);

    //!TODO ADD QUERY TO FILTER PRODUCTS NOT IN CATALOGE..
    subAdd = query.onChildAdded.listen(_onItemEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
  }

  @override
  void dispose() {
    super.dispose();
    subAdd?.cancel();
    subChanged?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      model.itemData = itemData;
      model.searchResult = searchResult;

      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: model.orderSum() > 0
              ? Padding(
                  child: Wrap(
                      spacing: 25,
                      runSpacing: 11,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Chip(
                          backgroundColor: Colors.grey[700],
                          avatar: CircleAvatar(
                            child: Text('Dh',
                                style: TextStyle(
                                    //color: Colors.green[400],
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          label: Text(
                            model.orderSum().toString(),
                            style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          backgroundColor: Colors.grey[700],
                          avatar: CircleAvatar(
                            child: Text('Bp',
                                style: TextStyle(
                                    //color: Colors.green[400],
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          label: Text(
                            model.orderBp().toString(),
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ]),
                  padding: EdgeInsets.only(right: 38),
                )
              : Container(),
          isExtended: true,
          elevation: 30,
          //onPressed:,
          icon: Icon(
            Icons.arrow_right,
            color: Colors.transparent,
          ),
          backgroundColor: Colors.transparent, onPressed: () {},
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            /* Switch(
                value: defaultDB,
                onChanged: (value) {
                  setState(() {
                    defaultDB = value;
                    defaultDB == true ? db = 'prouction' : db = 'stage';

                    print('dbvalue:$value');
                  });
                }),*/
            Container(
              height: 60,
              color: Theme.of(context).primaryColorLight,
              child: Card(
                child: ListTile(
                  leading: Icon(
                    Icons.search,
                    size: 24.0,
                  ),
                  title: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "",
                      border: InputBorder.none,
                    ),
                    // style: TextStyle(fontSize: 18.0),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: IconButton(
                    alignment: AlignmentDirectional.centerEnd,
                    icon: Icon(Icons.cancel, size: 20.0),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: searchResult.length != 0 || controller.text.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchResult.length,
                      itemBuilder: (context, i) {
                        return ItemCard(searchResult, i);
                      },
                    )
                  : ListView.builder(
                      itemCount: itemData.length,
                      itemBuilder: (context, index) {
                        return ItemCard(itemData, index);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  onSearchTextChanged(String text) {
    searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    itemData.where((i) => !i.disabled).forEach((item) {
      if (item.name.contains(text) || item.itemId.contains(text))
        searchResult.add(item);
    });
    setState(() {});
  }

  void _onItemEntryAdded(Event event) {
    //List<Item> items = List();
    itemData.add(Item.fromSnapshot(event.snapshot));
    // items.where((i) => !i.disabled).forEach((f) => itemData.add(f));
    //print("itemData length:${itemData.length}");
    setState(() {});
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = itemData.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      itemData[itemData.indexOf(oldEntry)] = Item.fromSnapshot(event.snapshot);
    });
  }
}
