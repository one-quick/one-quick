import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/models/clients_model.dart';
import 'package:socket_app/screens/send_message_page.dart';
import '../web_socket/web_socket_server.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomePage({required this.scaffoldKey, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<InternetAddress>> _clientDiscoveryFuture;

  @override
  void initState() {
    super.initState();
    _clientDiscoveryFuture = WebSocketServer().discoverWebSocketServers();
  }

  @override
  Widget build(BuildContext context) {
    final clientsModel = Provider.of<ClientsModel>(context);

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: FutureBuilder<List<InternetAddress>>(
        future: _clientDiscoveryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No connected clients'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final clientIp = snapshot.data![index].address;
                return ListTile(
                  title: Text(clientIp),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: clientsModel,
                          child: SendMessagePage(clientIp: clientIp),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
