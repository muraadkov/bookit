class NotificationPayloadModel {
  String to = '';
  NotificationContent notificationContent = NotificationContent(title: '', body: '');

  NotificationPayloadModel({required this.to, required this.notificationContent});

  NotificationPayloadModel.fromJson(Map<String, dynamic> data) {
    to = data['to'];
    notificationContent = data['notificationContent'] != null
        ? NotificationContent.fromJson(data['notificationContent'])
        : NotificationContent(title: '', body: '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['to'] = to;
    data['notificationContent'] = notificationContent.toJson();
    return data;
  }
}

class NotificationContent {
  String title = '', body = '';
  NotificationContent({required this.title, required this.body});
  NotificationContent.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    body = data['body'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    return data;
  }
}
