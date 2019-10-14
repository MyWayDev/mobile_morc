/*import 'package:flutter/material.dart';

class DmDialog extends StatefulWidget {
  int dmQty;
  DmDialog(this.dmQty, {Key key}) : super(key: key);

  _DmDialogState createState() => _DmDialogState();
}

class _DmDialogState extends State<DmDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Row(
          children: <Widget>[
            widget.dmQty != 0
                ? new IconButton(
                    icon: new Icon(Icons.remove),
                    onPressed: () => setState(() => widget.dmQty--),
                  )
                : new Container(),
            new Text(widget.dmQty.toString()),
            new IconButton(
                icon: new Icon(Icons.add),
                onPressed: () => setState(() => widget.dmQty++))
          ],
        ),
      ),
    );
  }
}*/
