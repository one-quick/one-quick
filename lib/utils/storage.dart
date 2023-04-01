import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _messagesKey = 'messages';

  static Future<void> saveMessage(String clientIp, String message, bool isFromServer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString(_messagesKey);
    List<dynamic> messages = messagesJson != null ? jsonDecode(messagesJson) : [];

    messages.add({
      'clientIp': clientIp,
      'message': message,
      'isFromServer': isFromServer,
    });

    prefs.setString(_messagesKey, jsonEncode(messages));
  }

  static Future<List<Map<String, dynamic>>> getMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString(_messagesKey);
    if (messagesJson == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(messagesJson));
  }
}
