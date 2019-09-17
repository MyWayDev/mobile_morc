import 'package:flutter/material.dart';

class RegistrationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              splashColor: Theme.of(context).primaryColor,
              color: Colors.pink[100],
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "تسجيل",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  new Expanded(
                    child: Container(),
                  ),
                  new Transform.translate(
                    offset: Offset(15.0, 0.0),
                    child: new Container(
                      padding: const EdgeInsets.all(5.0),
                      child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(28.0)),
                          splashColor: Colors.white,
                          color: Colors.white,
                          child: Icon(
                            Icons.person_add,
                            size: 32.0,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/registration')),
                    ),
                  )
                ],
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
