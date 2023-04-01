import 'package:flutter/foundation.dart';

class ClientsModel extends ChangeNotifier {
  final List<String> _clients = [];

  List<String> get clients => List.unmodifiable(_clients);

  void addClient(String clientIp) {
    _clients.add(clientIp);
    notifyListeners();
  }
}
