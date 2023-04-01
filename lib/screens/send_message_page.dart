import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/web_socket/web_socket_client.dart';
import 'package:socket_app/web_socket/web_socket_server.dart';

import '../models/clients_model.dart';

class SendMessagePage extends StatefulWidget {
  final WebSocketClient? webSocketClient;
  final String clientIp;

  const SendMessagePage({
    Key? key,
    this.webSocketClient,
    required this.clientIp,
  }) : super(key: key);

  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  late StreamSubscription<dynamic> _messageSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.webSocketClient != null) {
      _messageSubscription = widget.webSocketClient!.messages.listen((message) {
        print("Incoming message: $message"); // Debug print statement
        // Storage.saveMessage(widget.clientIp, message, true);
        Provider.of<ClientsModel>(context, listen: false).addMessage(
          widget.clientIp,
          message,
          false,
        );
      });
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (widget.webSocketClient != null && state == AppLifecycleState.paused) {
        widget.webSocketClient!.disconnect();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  void _sendMessage() {
    print("Outgoing message: ${_textController.text}"); // Debug print statement
    if (widget.webSocketClient != null) {
    Provider.of<ClientsModel>(context, listen: false).addMessage(
      widget.clientIp,
      _textController.text,
      true,
    );
      widget.webSocketClient!.sendMessage(_textController.text);
    } else {
      WebSocketServer().sendReplyTo(widget.clientIp, _textController.text);
    }
    _textController.clear();
  }

  Widget _buildMessage(Map<String, dynamic> messageData) {
    print(messageData);
    final isFromServer = messageData['isFromServer'];
    return ListTile(
      title: Text(messageData['message']),
      leading: isFromServer
          ? const Icon(Icons.arrow_forward)
          : const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsModel = Provider.of<ClientsModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.clientIp}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: clientsModel.getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data!
                    .where((msg) => msg['clientIp'] == widget.clientIp)
                    .toList();
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _messageSubscription.cancel();
    super.dispose();
  }
}
