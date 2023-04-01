import 'package:flutter/foundation.dart';

class ClientsModel extends ChangeNotifier {
  List<String> _clients = [];
  List<Map<String, dynamic>> _messages = [];

  List<String> get clients => _clients;
  List<Map<String, dynamic>> get messages => _messages;

  void addClient(String clientIp) {
    _clients.add(clientIp);
    notifyListeners();
  }

  void removeClient(String clientIp) {
    _clients.remove(clientIp);
    notifyListeners();
  }

  void addMessage(String clientIp, String message, bool isFromServer) {
    _messages.add({
      'clientIp': clientIp,
      'message': message,
      'isFromServer': isFromServer,
    });
    print('Message added: $message');
    print('Current messages: $_messages');
    notifyListeners();
  }
}
