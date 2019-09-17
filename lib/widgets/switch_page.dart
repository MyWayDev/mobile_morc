/*import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:n_gen/models/lock.dart';
import 'package:n_gen/pages/user/lock_screen.dart';

class SwitchPage extends StatefulWidget {
  final Widget page;
  SwitchPage(this.page);

  @override
  State<StatefulWidget> createState() {
    return _SwitchPage();
  }
}

bool _lock;
Future<bool> getlock(bool lockApp) async {
  final Lock getlock = Lock(lockApp: lockApp);
  return getlock.lockApp;
}

@override
class _SwitchPage extends State<SwitchPage> {
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference databaseReference;
    databaseReference = database
        .reference()
        .child('flamelink/environments/production/content/lockScreen/en-US');
    databaseReference.onValue.listen((event) async {
      _lock = await getlock(Lock.fromSnapshot(event.snapshot).lockApp);
      print(_lock);

      setState(() {});
    });

    // databaseReference.onChildAdded.listen(_lockAdded);
    //databaseReference.onChildChanged.listen(_lockChanged);
  }

  Widget build(BuildContext context) {
    return _lockScreen(context, widget.page);
  }

  Widget _lockScreen(BuildContext context, Widget page) {
    return _lock == false ? page : LockScreen();
  }
}*/
