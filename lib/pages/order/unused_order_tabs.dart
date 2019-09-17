import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/pages/gift/gift.dart';
import 'package:mor_release/pages/order/end_order.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/switch_page.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderTabs extends StatelessWidget {
  OrderTabs();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      model.rungiftState();
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            ///////////////////////Top Tabs Navigation Widget//////////////////////////////
            title: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.local_shipping,
                    size: 35.0,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              EndOrder(),
              GiftPage(),
              //ProductList(),
            ],
          ),
        ),
      );
    });
  }
}
