import 'package:firebase_database/firebase_database.dart';

class Area {
  String areaId;
  String name;

  Area({this.areaId, this.name});

  Area.fromSnapshot(DataSnapshot snapshot)
      : areaId = snapshot.value['areaId'],
        name = snapshot.value['name'];

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(areaId: json['AREA_ID'], name: json['ANAME']);
  }
  toJson() {
    return {
      "areaId": areaId,
      "name": name,
      "id": areaId,
    };
  }
}
