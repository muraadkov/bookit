import 'package:bookit/model/services_model.dart';
import 'package:bookit/state/state_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<ServicesModel>> getServices(BuildContext context, WidgetRef ref) async {
  var services = List<ServicesModel>.empty(growable: true);
  CollectionReference servicesRef = FirebaseFirestore.instance.collection('Services');
  QuerySnapshot snapshot =
      await servicesRef.where('facility_name', isEqualTo: ref.read(selectedFacility).name).get();
  snapshot.docs.forEach((element) {
    final data = element.data() as Map<String, dynamic>;
    var servicesModel = ServicesModel.fromJson(data);
    servicesModel.docId = element.id;
    services.add(servicesModel);
  });
  return services;
}
