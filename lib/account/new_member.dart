import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

import 'package:intl/intl.dart';

class NewMemberPage extends StatefulWidget {
  final List<Area> areas;
  NewMemberPage(this.areas);
  State<StatefulWidget> createState() {
    return _NewMemberPage();
  }
}

//final FirebaseDatabase dataBase = FirebaseDatabase.instance;
@override
class _NewMemberPage extends State<NewMemberPage> {
  DateTime selected;

  _showDateTimePicker() async {
    selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));
    // locale: Locale('fr'));

    setState(() {});
  }

  //final model = MainModel();

  void initState() {
    super.initState();
  }

  TextEditingController controller = new TextEditingController();

  final GlobalKey<FormState> _newMemberFormKey = GlobalKey<FormState>();

  final NewMember _newMemberForm = NewMember(
    sponsorId: null,
    familyName: null,
    name: null,
    personalId: null,
    birthDate: null,
    email: null,
    telephone: null,
    address: null,
    areaId: null,
  );

  Area stateValue;

  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  bool veri = false;
  //int _courier;
  User _nodeData;

  void resetVeri() {
    controller.clear();
    veri = false;
  }

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  bool validateAndSave(String userId) {
    final form = _newMemberFormKey.currentState;
    isloading(true);
    if (form.validate()) {
      _newMemberForm.birthDate =
          DateFormat('yyyy-MM-dd').format(selected).toString();
      _newMemberForm.email = userId;
      // isloading(true);
      print('valide entry');
      _newMemberFormKey.currentState.save();

      print('${_newMemberForm.sponsorId}:${_newMemberForm.birthDate}');
      isloading(false);
      return true;
    }
    isloading(false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: ModalProgressHUD(
          child: Container(
            child: buildRegForm(context),
          ),
          inAsyncCall: _isloading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
        ),
      );
    });
  }

  Widget buildRegForm(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.dstATop),
            image: AssetImage('assets/images/background.jpg'),
          ),
        ),
        child: Form(
          key: _newMemberFormKey,
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 8),
                        leading: Icon(Icons.vpn_key,
                            size: 25.0, color: Colors.pink[500]),
                        title: TextFormField(
                          textAlign: TextAlign.center,
                          controller: controller,
                          enabled: !veri ? true : false,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: ' ادخل رقم العضو الراعى',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value.isEmpty
                              ? 'Code is Empty !!'
                              : RegExp('[0-9]').hasMatch(value)
                                  ? null
                                  : 'invalid code !!',
                          onSaved: (_) {
                            _newMemberForm.sponsorId = _nodeData.distrId;
                          },
                        ),
                        trailing: IconButton(
                          icon: !veri && controller.text.length > 0
                              ? Icon(
                                  Icons.check,
                                  size: 30.0,
                                  color: Colors.blue,
                                )
                              : controller.text.length > 0
                                  ? Icon(
                                      Icons.close,
                                      size: 28.0,
                                      color: Colors.grey,
                                    )
                                  : Container(),
                          color: Colors.pink[900],
                          onPressed: () async {
                            if (!veri) {
                              veri = await model.leaderVerification(
                                  controller.text.padLeft(8, '0'));
                              if (veri) {
                                _nodeData = await model
                                    .nodeJson(controller.text.padLeft(8, '0'));
                                controller.text =
                                    _nodeData.distrId + '    ' + _nodeData.name;
                              } else {
                                resetVeri();
                              }
                            } else {
                              resetVeri();
                            }
                          },
                          splashColor: Colors.pink,
                        ),
                      ),
                      veri
                          ? Container(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: RawMaterialButton(
                                      child: Icon(
                                        GroovinMaterialIcons.calendar_check,
                                        size: 26.0,
                                        color: Colors.white,
                                      ),
                                      shape: CircleBorder(),
                                      highlightColor: Colors.pink[500],
                                      elevation: 8,
                                      fillColor: Colors.pink[500],
                                      onPressed: () {
                                        _showDateTimePicker();
                                      },
                                      splashColor: Colors.pink[900],
                                    ),
                                    title: selected != null
                                        ? Text(DateFormat('yyyy-MM-dd')
                                            .format(selected)
                                            .toString())
                                        : Text(''),
                                    subtitle: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: selected == null
                                          ? Text('تاريخ الميلاد')
                                          : Text(''),
                                    ),

                                    //trailing:
                                  ),
                                  Divider(
                                    height: 6,
                                    color: Colors.black,
                                  ),
                                  /*  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'الاسم العائلي',
                                        contentPadding: EdgeInsets.all(8.0),
                                        icon: Icon(
                                            GroovinMaterialIcons.format_size,
                                            color: Colors.pink[500])),
                                    validator: (value) {},
                                    keyboardType: TextInputType.text,
                                    onSaved: (String value) {
                                      _newMemberForm.familyName = value;
                                    },
                                  ),*/
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'اسم العضو',
                                        contentPadding: EdgeInsets.all(8.0),
                                        icon: Icon(
                                            GroovinMaterialIcons.format_title,
                                            color: Colors.pink[500])),
                                    validator: (value) {},
                                    keyboardType: TextInputType.text,
                                    onSaved: (String value) {
                                      _newMemberForm.name = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'الرقم الوطنى',
                                        contentPadding: EdgeInsets.all(8.0),
                                        icon: Icon(Icons.assignment_ind,
                                            color: Colors.pink[500])),
                                    autocorrect: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    onSaved: (String value) {
                                      _newMemberForm.personalId = value;
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'ارقم الهاتف',
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.all(8.0),
                                        icon: Icon(
                                          Icons.phone,
                                          color: Colors.pink[500],
                                        )),
                                    keyboardType: TextInputType.number,
                                    onSaved: (String value) {
                                      _newMemberForm.telephone = value;
                                    },
                                  ),
                                  /*  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'البريد',
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.all(8.0),
                                        icon: Icon(
                                          Icons.email,
                                          color: Colors.pink[500],
                                        )),
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (String value) {
                                      _newMemberForm.email = value;
                                    },
                                  ),*/
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'العنوان',
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.all(8.0),
                                        icon: Icon(
                                          GroovinMaterialIcons.home,
                                          color: Colors.pink[500],
                                        )),
                                    keyboardType: TextInputType.text,
                                    onSaved: (String value) {
                                      _newMemberForm.address = value;
                                    },
                                  ),
                                  FormField<Area>(
                                    initialValue: _newMemberForm.areaId = null,
                                    onSaved: (val) =>
                                        _newMemberForm.areaId = val.areaId,
                                    validator: (val) => (val == null)
                                        ? 'Please choose a area'
                                        : null,
                                    builder: (FormFieldState<Area> state) {
                                      return InputDecorator(
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          icon: Icon(
                                            GroovinMaterialIcons
                                                .map_marker_radius,
                                            color: Colors.pink[500],
                                          ),
                                          labelText: stateValue == null
                                              ? 'المنطقه'
                                              : '',
                                          errorText: state.hasError
                                              ? state.errorText
                                              : null,
                                        ),
                                        isEmpty: state.value == null,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Area>(
                                            // iconSize: 25.0,
                                            // elevation: 5,
                                            value: stateValue,
                                            // isDense: true,
                                            onChanged: (Area newValue) async {
                                              if (newValue.areaId == '') {
                                                newValue = null;
                                              }
                                              setState(() {
                                                stateValue = newValue;
                                              });

                                              state.didChange(newValue);

                                              print('AreaId${newValue.areaId}');
                                            },
                                            items:
                                                widget.areas.map((Area area) {
                                              return DropdownMenuItem<Area>(
                                                value: area,
                                                child: Text(
                                                  area.name,
                                                  style: TextStyle(
                                                    color: Colors.pink[900],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Container()
                    ]),
                  ),
                ),
              ),
              veri
                  ? Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 10.0),
                          ),
                          Expanded(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              splashColor: Theme.of(context).primaryColor,
                              color: Colors.pink[900],
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      "",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Transform.translate(
                                    offset: Offset(15.0, 0.0),
                                    child: Container(
                                      //   padding: const EdgeInsets.all(0.0),
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(28.0)),
                                        splashColor: Colors.white,
                                        color: Colors.white,
                                        child: Icon(
                                          GroovinMaterialIcons
                                              .account_multiple_check,
                                          size: 25.0,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onPressed: () async {
                                          validateAndSave(
                                              model.userInfo.distrId);
                                          String msg = await _saveNewMember(
                                              model.userInfo.distrId);

                                          _newMemberFormKey.currentState
                                              .reset();
                                          showReview(context, msg);
                                          //   _regPressed();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                validateAndSave(model.userInfo.distrId);
                                String msg = await _saveNewMember(
                                    model.userInfo.distrId);

                                _newMemberFormKey.currentState.reset();
                                showReview(context, msg);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    });
  }

  String errorM = '';
  Future<String> _saveNewMember(String user) async {
    Id body;
    String msg;
    isloading(true);
    print(_newMemberForm.postNewMemberToJson(_newMemberForm));
    Response response = await _newMemberForm.createPost(_newMemberForm, user);
    if (response.statusCode == 201) {
      body = Id.fromJson(json.decode(response.body));
      msg = body.id;
    } else {
      msg = "خطأ فى حفظ البيانات";
    }
    print(response.statusCode);
    print(msg);
    isloading(false);
    return msg;
  }

  Future<bool> showReview(BuildContext context, String msg) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              height: 110.0,
              width: 110.0,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        ' رقم العضويه: $msg ',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/bottomnav', (_) => false);
                    },
                    child: Container(
                      height: 35.0,
                      width: 35.0,
                      color: Colors.white,
                      child: Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
/*
  void _regPressed() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (validateAndSave()) {
      await initlegacyData(_registrationFormData['userId'])
          .catchError((e) => '');
      await fireData(_registrationFormData['userId']).catchError((e) => '');
      if (!_legacyDataExits || _fireDataExits) {
        errorM = 'wrong code';
        print('legacyDataExits:$_legacyDataExits');
        print('fireDataExits:$_fireDataExits');
        isloading(false);
        print(errorM);
      } else {
        print('legacyDataExits:$_legacyDataExits');
        print('fireDataExits:$_fireDataExits');
        errorM = 'Good to GO';
        print(errorM);
        validateAndSubmit();
      }
    }
        TextFormField(
                        decoration: InputDecoration(
                            labelText: 'رقم العضو الراعي',
                            contentPadding: EdgeInsets.all(8.0),
                            icon: Icon(Icons.vpn_key, color: Colors.pink[500])),
                        //autocorrect: true,
                        autofocus: true,
                        //autovalidate: true,
                        // initialValue: '00000000',
                        validator: (value) => value.isEmpty
                            ? 'رقم العضويه !!'
                            : RegExp('[0-9]').hasMatch(value)
                                ? null
                                : 'رقم العضويه !!',

                        keyboardType: TextInputType.number,
                        onSaved: (String value) {
                          _newMemberFormData['sponsorId'] =
                              value.padLeft(8, '0');
                        },
                      ),
  }*/
}

class Id {
  String id;

  Id({this.id});

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(id: json['id']);
  }
}
