import 'package:flutter/material.dart';
import 'package:socket_app/utils/storage.dart';
import 'package:socket_app/web_socket/web_socket_server.dart';

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
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    List<Map<String, dynamic>> messages = await Storage.getMessages();
    setState(() {
      _messages = messages.where((msg) => msg['clientIp'] == widget.clientIp).toList();
    });
  }

  void _sendMessage() {
    WebSocketServer().sendReplyTo(widget.clientIp, _textController.text);
    Storage.saveMessage(widget.clientIp, _textController.text, true);
    setState(() {
      _messages.add({
        'clientIp': widget.clientIp,
        'message': _textController.text,
        'isFromServer': true,
      });
    });
    _textController.clear();
  }

  Widget _buildMessage(Map<String, dynamic> messageData) {
    final isFromServer = messageData['isFromServer'];
    return ListTile(
      title: Text(messageData['message']),
      leading: isFromServer ? const Icon(Icons.arrow_back) : const Icon(Icons.arrow_forward),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.clientIp}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
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
