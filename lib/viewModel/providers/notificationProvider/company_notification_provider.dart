import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_brand/models/notification/company_notification_model.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:http/http.dart' as http;

class CompanyNotificationProvider extends ChangeNotifier {
  List<CompanyNotificationModel> notifications = [];
  int unreadCount = 0;
  bool loading = false;

  Future<void> fetchNotifications() async {
    if (loading) return;
    loading = true;
    notifyListeners();

    try {
      final token = await LocalStorage.getToken();
      final res = await http.get(
        Uri.parse('${Global.BaseUrl}/company/notifications?limit=50'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        notifications = (json['notifications'] as List)
            .map((e) => CompanyNotificationModel.fromJson(e))
            .toList();
        unreadCount = json['unreadCount'] ?? 0;
      }
    } catch (_) {}

    loading = false;
    notifyListeners();
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    try {
      final token = await LocalStorage.getToken();
      await http.put(
        Uri.parse('${Global.BaseUrl}/company/notifications/mark-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      unreadCount = 0;
      notifications = notifications
          .map((n) => CompanyNotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                type: n.type,
                data: n.data,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
      notifyListeners();
    } catch (_) {}
  }
}
