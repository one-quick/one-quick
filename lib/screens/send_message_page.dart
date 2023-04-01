import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/utils/storage.dart';
import 'package:socket_app/web_socket/web_socket_server.dart';

import '../models/clients_model.dart';

class SendMessagePage extends StatefulWidget {
  final String clientIp;

  const SendMessagePage({
    Key? key,
    required this.clientIp,
  }) : super(key: key);

  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() {
    WebSocketServer().sendReplyTo(widget.clientIp, _textController.text);
    Storage.saveMessage(widget.clientIp, _textController.text, true);
    Provider.of<ClientsModel>(context, listen: false).addMessage(
      widget.clientIp,
      _textController.text,
      true,
    );
    _textController.clear();
  }

  Widget _buildMessage(Map<String, dynamic> messageData) {
    final isFromServer = messageData['isFromServer'];
    return ListTile(
      title: Text(messageData['message']),
      leading: isFromServer
          ? const Icon(Icons.arrow_back)
          : const Icon(Icons.arrow_forward),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsModel = Provider.of<ClientsModel>(context);
    print(clientsModel.messages);
    final messages = clientsModel.messages
        .where((msg) => msg['clientIp'] == widget.clientIp)
        .toList();
    print('Fetched messages: $messages');
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.clientIp}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
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
    super.dispose();
  }
}
