/*import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/account/new_member.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class AccountTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      // model.userDetails();

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            ///////////////////////Top Tabs Navigation Widget//////////////////////////////
            title: TabBar(
              indicatorColor: Colors.grey[400],
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    GroovinMaterialIcons.account_multiple_plus,
                    size: 32.0,
                    color: Colors.grey[350],
                  ),
                ),
                Tab(
                  child: BadgeIconButton(
                    itemCount: model.itemCount() < 0 || model.itemCount() > 0
                        ? 0
                        : model.itemCount(), // required
                    icon: Icon(
                      GroovinMaterialIcons.file_account,
                      color: Colors.transparent,
                      size: 1.0,
                    ), // required
                    //badgeColor: Colors.red, // default: Colors.red
                    badgeTextColor: Colors.white, // default: Colors.white
                    //hideZeroCount: true, // default: true
                  ),
                ), //!
              ],
            ),
          ),
          ////v////////////////////Bottom Tabs Navigation widget/////////////////////////
          body: TabBarView(
            children: <Widget>[
              // NewMemberPage(model.areas),
              Container(), // SwitchPage(ItemsPage()),
              //OrderPage(), //SwitchPage(OrderPage()),
              //ProductList(),
            ],
          ),
        ),
      );
    });
  }
}*/
/* bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                  title: new Text('Account'),
                  icon: new Icon(Icons.account_box)),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.mail), title: new Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('Profile'))
            ],
          ),*/
/*new BottomNavigationBarItem(
        title: new Text('Home'),
        icon: new Stack(
          children: <Widget>[
            new Icon(Icons.home),
            new Positioned(  // draw a red marble
              top: 0.0,
              right: 0.0,
              child: new Icon(Icons.brightness_1, size: 8.0, 
                color: Colors.redAccent),
            )
          ]
        ),
      )*/
