import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_app/utils/storage.dart';

class ClientsModel with ChangeNotifier {
  final List<String> _clients = [];
  final StreamController<List<String>> _clientsStreamController = StreamController.broadcast();

  List<String> get clients => _clients;

  Stream<List<String>> get clientsStream => _clientsStreamController.stream;

  void addClient(String ip) {
    _clients.add(ip);
    _clientsStreamController.add(_clients);
    notifyListeners();
  }

  void removeClient(String ip) {
    _clients.remove(ip);
    _clientsStreamController.add(_clients);
    notifyListeners();
  }

  Future<void> addMessage(String ip, String message, bool isFromServer) async {
    await Storage.saveMessage(ip, message, isFromServer);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    return await Storage.getMessages();
  }

  @override
  void dispose() {
    _clientsStreamController.close();
    super.dispose();
  }
}
