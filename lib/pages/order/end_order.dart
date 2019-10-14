import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/pages/order/member_order.dart';
import 'package:mor_release/pages/order/node_order.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class EndOrder extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _EndOrder();
  }
}

@override
class _EndOrder extends State<EndOrder> with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;
  NodeOrder nodeOrder;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.blue,
      end: Colors.black45,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animateii() {}
  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggleii() {
    return FloatingActionButton(
        backgroundColor: Colors.white, onPressed: animateii, child: Container()
        /*AnimatedIcon(
        icon: AnimatedIcons.menu_home,
        progress: _animateIcon,
      ),*/
        );
  }

  Widget toggle() {
    return FloatingActionButton(
      elevation: 20,
      backgroundColor: _animateColor.value,
      onPressed: animate,
      tooltip: 'Toggle',
      child: AnimatedIcon(
        icon: AnimatedIcons.home_menu,
        progress: _animateIcon,
      ),
    );
  }

  bool _isloading = false;
  void settings(MainModel model) async {
    await model.settingsData();
  }

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  TextEditingController controller = new TextEditingController();
  bool _isleader = false;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      _isleader = model.userInfo.isleader;
      model.rungiftState();
      settings(model);
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              model.userInfo.name,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ]),
          actions: <Widget>[],
          leading: model.isTypeing
              ? Container()
              : !isOpened
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                      ),
                      onPressed: () {
                        model.isTypeing = false;
                        Navigator.of(context).pop(null);
                      })
                  : Container(),
        ),
        floatingActionButton:
            _isleader && !model.isTypeing ? toggle() : toggleii(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        body: ModalProgressHUD(
          child: Column(
            children: <Widget>[
              Card(
                elevation: 5,
                child: isOpened
                    ? NodeOrder()
                    : MemberOrder(model.courierList(model.userInfo.areaId),
                        model.userInfo.areaId),
              ),
            ],
          ),
          inAsyncCall: _isloading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
        ),
      );
    });
  }
}
/*
 appBar: AppBar(
            title: _isleader
                ? GridTileBar(
                    title: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 60.0),
                        ),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                model.userInfo.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ))
                        /* Switch(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeTrackColor: Colors.black38,
                          activeColor: Colors.black,
                          value: _leaderSwitch,
                          onChanged: (bool value) {
                            setState(() {
                              _leaderSwitch = value;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                : Container()),*/
*/
