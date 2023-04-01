import 'package:flutter/foundation.dart';

class ClientsModel extends ChangeNotifier {
  List<String> _clients = [];

  List<String> get clients => _clients;

  void addClient(String clientIp) {
    _clients.add(clientIp);
    notifyListeners();
  }

  void removeClient(String clientIp) {
    _clients.remove(clientIp);
    notifyListeners();
  }

  void addMessage(String clientIp, String message, bool isFromServer) {
    // No need to update the state here, as the messages are loaded from local storage in the SendMessagePage
  }
}
