import 'dart:io';
import 'dart:async';

import 'package:socket_app/utils/storage.dart';

import '../models/clients_model.dart';

class WebSocketServer {
  static final WebSocketServer _singleton = WebSocketServer._internal();
  HttpServer? _server;
  final Map<String, WebSocket> _clients = {};
  late ClientsModel _clientsModel;
  factory WebSocketServer() {
    return _singleton;
  }

  WebSocketServer._internal();

  final Completer<void> _readyCompleter = Completer<void>();

  Map<String, WebSocket> get clients => _clients;

  Future<void> start(
    String address,
    int port, {
    required ClientsModel clientsModel,
  }) async {
    _clientsModel = clientsModel;
    _server = await HttpServer.bind(address, port);
    print('Server bound: ${_server != null}');
    _readyCompleter.complete();
    _server!.listen((HttpRequest request) async {
      if (request.uri.path == '/ws' &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        print('WebSocket upgrade request received');
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        String ip = request.connectionInfo?.remoteAddress.address ?? "unknown";
        _clients[ip] = socket;
        print('Client connected: $ip');
        print(_clients);
        clientsModel.addClient(ip);
        socket.listen(
          (message) {
            print("Message from $ip: $message");
            Storage.saveMessage(ip, message, false);
            clientsModel.addMessage(ip, message, false);
          },
          onError: (error) {
            print("Error from $ip: $error");
          },
          onDone: () {
            print("Client disconnected: $ip");
            _clients.remove(ip);
            clientsModel.removeClient(ip);
          },
        );
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not found')
          ..close();
      }
    });
    print('WebSocket server listening on ws://$address:$port/ws');
  }

  Future<void> waitForReady() => _readyCompleter.future;

  void stop() async {
    await _server?.close(force: true);
  }

  void sendReplyTo(String ip, String message) {
    WebSocket? client = _clients[ip];
    if (client != null) {
      client.add("Server reply: $message");
    } else {
      print("Client not found for IP: $ip");
    }
  }
}
