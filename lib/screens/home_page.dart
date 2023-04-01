import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/models/clients_model.dart';
import 'package:socket_app/screens/send_message_page.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomePage({required this.scaffoldKey, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    final clientsModel = Provider.of<ClientsModel>(context);

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: clientsModel.clients.isEmpty
          ? const Center(child: Text('No connected clients'))
          : ListView.builder(
              itemCount: clientsModel.clients.length,
              itemBuilder: (context, index) {
                final clientIp = clientsModel.clients[index];
                return ListTile(
                  title: Text(clientIp),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SendMessagePage(clientIp: clientIp),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
