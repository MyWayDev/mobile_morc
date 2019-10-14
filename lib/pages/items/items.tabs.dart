import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/pages/items/items.dart';
import 'package:mor_release/pages/messages/local_note.dart';
import 'package:mor_release/pages/order/order.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/track/track.tabs.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:badges/badges.dart';
import '../../cat.dart';
import '../profile.dart';

//////////////////////////////////////////////////////
///
///!notification badge over icon example code

class ItemsTabs extends StatelessWidget {
  ItemsTabs();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      model.userDetails();
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          drawer: Drawer(
              child: Column(children: <Widget>[
            AppBar(
              title: Text('القائمه'),
            ),
            ListTile(
                leading: Icon(Icons.settings),
                title: Text('Profile'),
                onTap: () {
                  //model.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                }),
            ListTile(
                leading: Icon(Icons.image),
                title: Text('Cat'),
                onTap: () {
                  print(model.settings.pdfUrl);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Cat(
                                pdfUrl: model.settings.pdfUrl,
                              )));
                }),
            ListTile(
                leading: Icon(Icons.backspace),
                title: Text('خروج'),
                onTap: () {
                  model.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                }),
          ])),
          appBar: AppBar(
            ///////////////////////Top Tabs Navigation Widget//////////////////////////////
            title: TabBar(
              indicatorColor: Colors.grey[400],
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.home,
                    size: 26.0,
                    color: Colors.grey[350],
                  ),
                ),
                Tab(
                  child: BadgeIconButton(
                    itemCount: model.itemCount() < 0
                        ? 0
                        : model.itemCount(), // required
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.grey[350],
                      size: 26.0,
                    ), // required
                    //badgeColor: Colors.red, // default: Colors.red
                    badgeTextColor: Colors.white, // default: Colors.white
                    //hideZeroCount: true, // default: true
                  ),
                  /* icon: new Stack(children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          size: 35.0,
                        ),
                        Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: )
                      ]),*/
                ),
                Tab(
                  icon: new Icon(
                    GroovinMaterialIcons.file_find,
                    size: 26.0,
                    color: Colors.grey[350],
                  ),
                ),
                Tab(
                    child: BadgeIconButton(
                  itemCount: model.noteCount,
                  badgeColor: Colors.lightBlueAccent,
                  badgeTextColor: Colors.white,
                  icon: Icon(
                    Icons.notifications,
                    size: 26.0,
                    color: Colors.grey[350],
                  ),
                ))
              ],
            ),
          ),
          ////////////////////////Bottom Tabs Navigation widget/////////////////////////
          body: TabBarView(
            children: <Widget>[
              ItemsPage(), // SwitchPage(ItemsPage()),
              OrderPage(), //SwitchPage(OrderPage()),
              TrackTabs(),
              LocalNotification(
                token: model.token,
              ),

              //ProductList(),
            ],
          ),
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
        ),
      );
    });
  }
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

  /* Widget _currentUser(BuildContext context, MainModel model) {
    return new FutureBuilder(
      future: model.loggedUser(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData)
          return Text(snapshot.data);
        else
          return Text('*');
      },
    );
  }*/
}

enum db { production, stage }
