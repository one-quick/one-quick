import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  late WebSocketChannel _channel;

  void connect(String ipAddress, int port) {
    _channel = IOWebSocketChannel.connect('ws://$ipAddress:$port');
  }

  void disconnect() {
    _channel.sink.close();
  }

  Stream<dynamic> get messages => _channel.stream;

  void sendMessage(String message) {
    _channel.sink.add(message);
  }
}
