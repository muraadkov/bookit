import 'dart:convert';

import 'package:bookit/cloud_firestore/app_data_ref.dart';
import 'package:bookit/model/notification_payload_model.dart';
import 'package:dio/dio.dart';

Future<bool> sendNotification(NotificationPayloadModel notificationPayloadModel) async {
  var dataSubmit = jsonEncode(notificationPayloadModel);
  var key = await getServerKey();
  var result = await Dio().post('https://fcm.googleapis.com/fcm/send',
      options: Options(
          headers: {
            Headers.acceptHeader: 'application/json',
            Headers.contentTypeHeader: 'application/json',
            'Authorization': 'key=$key'
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          followRedirects: false,
          validateStatus: (status) => status! < 500),
      data: dataSubmit);
  return result.statusCode == 200 ? true : false;
}
