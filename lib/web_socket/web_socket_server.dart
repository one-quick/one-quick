import 'dart:io';
import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/clients_model.dart';
import '../utils/advertisement.dart';

class WebSocketServer {
  static final WebSocketServer _singleton = WebSocketServer._internal();
  HttpServer? _server;
  final Map<String, WebSocket> _clients = {};
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
    _server = await HttpServer.bind(address, port);
    print('Server bound: ${_server != null}');
    _readyCompleter.complete();
    WebSocketServiceAdvertiser.registerService(port);
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
    WebSocketServiceAdvertiser.unregisterService();
    await _server?.close(force: true);
  }

  void sendReplyTo(String ip, String message) {
    WebSocket? client = _clients[ip];
    if (client != null) {
      client.add("Server reply: $message");
      ClientsModel().addMessage(ip, message, true);
    } else {
      print("Client not found for IP: $ip");
    }
  }

  Future<List<InternetAddress>> discoverWebSocketServers() async {
    const String name = "_one-quick._tcp";
    final MDnsClient client = MDnsClient();
    await client.start();

    final List<InternetAddress> availableServers = [];

    await for (final PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName))) {
        await for (final IPAddressResourceRecord ip
            in client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target))) {
          final info = NetworkInfo();
          var address = await info.getWifiIP() ?? "0.0.0.0";
          print(ip.address);
          if (ip.address.address != address) {
            availableServers.add(ip.address);
          }
        }
      }
    }

    client.stop();
    print(availableServers);
    return availableServers;
  }
}
