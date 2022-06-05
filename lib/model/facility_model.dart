import 'package:cloud_firestore/cloud_firestore.dart';

class FacilityModel {
  String name = '', address = '', city = '', details = '', imageUrl = '';
  int cheque = 0;
  bool isPopular = false;
  String? docId = '';
  DocumentReference? reference;

  FacilityModel(
      {required this.name,
      required this.address,
      required this.city,
      required this.details,
      required this.cheque,
      required this.isPopular,
      required this.imageUrl});

  FacilityModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    name = json['name'];
    cheque = json['cheque'];
    city = json['city'];
    details = json['details'];
    isPopular = json['isPopular'];
    imageUrl = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['name'] = name;
    data['cheque'] = cheque;
    data['city'] = city;
    data['details'] = details;
    data['isPopular'] = isPopular;
    data['image'] = imageUrl;
    return data;
  }
}
