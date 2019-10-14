import 'package:flutter/material.dart';
import '../../models/item.dart';

class ItemDetails extends StatelessWidget {
  final Item item;

  ItemDetails(this.item);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, false);
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(item.name),
            ),
            body: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.network(item.imageUrl ??
                        '' // 'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F${item.image[0].toString()}_${item.itemId}.png?alt=media&token=274fc65f-8295-43d5-909c-e2b174686439',
                    ),
                Container(
                    padding: EdgeInsets.all(10.0), child: Text(item.name)),
                Container(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(item.usage),
                    ),
                  ),
                )
              ],
            )));
  }
}
