import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';

class User {
  String key;
  String distrId;
  String name;
  String distrIdent;
  String email;
  String phone;
  String areaId;
  String photoUrl;
  bool isAllowed;
  bool isleader;
  String token;

  User(
      {this.distrId,
      this.email,
      this.distrIdent,
      this.phone,
      this.name,
      this.areaId,
      this.photoUrl,
      this.isAllowed,
      this.isleader,
      this.token});

  toJson() {
    return {
      "IsAllowed": true,
      "distrId": distrId,
      "distrIdent": distrIdent,
      "email": email,
      "id": int.parse(distrId).toString(),
      "isleader": false,
      "areaId": areaId,
      "name": name,
      "tele": phone,
    };
  }

  factory User.formJson(Map<String, dynamic> json) {
    return User(
      distrId: json['DISTR_ID'],
      name: json['ANAME'],
      distrIdent: json['DISTR_IDENT'],
      email: json['E_MAIL'],
      phone: json['TELEPHONE'],
      areaId: json['AREA_ID'],
    );
  }
  // * firebase sample code for model..
  User.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        distrId = snapshot.value["distrId"],
        email = snapshot.value["email"],
        isAllowed = snapshot.value["IsAllowed"],
        isleader = snapshot.value["isleader"],
        areaId = snapshot.value["areaId"],
        token = snapshot.value["token"],
        photoUrl = snapshot.value["photoUrl"];

  User.useSnapshot(DataSnapshot snapshot)
      : name = snapshot.value["name"],
        distrId = snapshot.value["distrId"],
        email = snapshot.value["email"],
        isAllowed = snapshot.value["IsAllowed"],
        isleader = snapshot.value["isleader"],
        areaId = snapshot.value["areaId"],
        token = snapshot.value["token"],
        photoUrl = snapshot.value["photoUrl"];
}

class NewMember {
  String sponsorId;
  String familyName;
  String name;
  String personalId;
  String birthDate;
  String email;
  String telephone;
  String address;
  String areaId;

  NewMember({
    this.sponsorId,
    this.familyName,
    this.name,
    this.personalId,
    this.birthDate,
    this.email,
    this.telephone,
    this.address,
    this.areaId,
  });
  Map<String, dynamic> toJson() => {
        "SPONSOR_ID": sponsorId,
        "FAMILY_ANAME": familyName,
        "ANAME": name,
        "DISTR_IDENT": personalId,
        "BIRTH_DATE": birthDate,
        "E_MAIL": email,
        "TELEPHONE": telephone,
        "ADDRESS": address,
        "AREA_ID": areaId,
      };
  String postNewMemberToJson(NewMember newMember) {
    final dyn = newMember.toJson();
    return json.encode(dyn);
  }

  Future<http.Response> createPost(NewMember newMember, String user) async {
    final response = await http.put(
        'http://mywayapi.azurewebsites.net/api/memregister/$user',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: ''
        },
        body: postNewMemberToJson(newMember));

    return response;
  }
}

class Member {
  String distrId;
  String name;
  var perBp;
  var grpBp;
  var totBp;
  var ratio;
  String leaderId;
  String sponsorId;
  var grpCount;
  String area;
  String lastUpdate;
  String nextUpdate;

  Member({
    this.distrId,
    this.name,
    this.perBp,
    this.grpBp,
    this.totBp,
    this.ratio,
    this.leaderId,
    this.sponsorId,
    this.grpCount,
    this.area,
    this.lastUpdate,
    this.nextUpdate,
  });

  factory Member.formJson(Map<String, dynamic> json) {
    return Member(
      distrId: json['distr_id'],
      name: json['M_ANAME'],
      perBp: json['per_bp'],
      grpBp: json['PGROUP_BP'],
      totBp: json['TOTAL_BP'],
      ratio: json['m_ratio'],
      leaderId: json['LEADER_ID_N'],
      sponsorId: json['SPONSOR_ID'],
      grpCount: json['COUNT'],
      area: json['AREA'],
      lastUpdate: json['LASTUPDATE'],
      nextUpdate: json['NEXTUPDATE'],
    );
  }
}
