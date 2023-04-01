import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/models/clients_model.dart';
import 'package:socket_app/screens/send_message_page.dart';
import 'package:socket_app/web_socket/web_socket_client.dart';
import 'package:socket_app/web_socket/web_socket_server.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomePage({required this.scaffoldKey, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<InternetAddress>> _clientDiscoveryFuture;
  final WebSocketClient _webSocketClient = WebSocketClient();
  final WebSocketServer _webSocketServer = WebSocketServer();
  final int webSocketPort = 8000; // Set the WebSocket port you are using

  @override
  void initState() {
    super.initState();
    _clientDiscoveryFuture = _webSocketServer.discoverWebSocketServers();
  }

  @override
  void dispose() {
    _webSocketClient.disconnect();
    super.dispose();
  }

  Widget _buildClientList(List<InternetAddress> discoveredServers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: discoveredServers.length,
      itemBuilder: (context, index) {
        final ip = discoveredServers[index].address;
        final webSocketClient = WebSocketClient();
        webSocketClient.connect(ip, webSocketPort);
        return ListTile(
          title: Text(ip),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: Provider.of<ClientsModel>(context),
                  child: SendMessagePage(
                    clientIp: ip,
                    webSocketClient: webSocketClient,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServerList(List<String> connectedClients) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: connectedClients.length,
      itemBuilder: (context, index) {
        final clientIp = connectedClients[index];
        return ListTile(
          title: Text(clientIp),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: Provider.of<ClientsModel>(context),
                  child: SendMessagePage(
                    clientIp: clientIp,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsModel = Provider.of<ClientsModel>(context);

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: const Text('One Quick'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
            ),
            Expanded(
              child: FutureBuilder<List<InternetAddress>>(
                future: _clientDiscoveryFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    final discoveredServers = snapshot.data!;
                    final connectedClients = clientsModel.clients;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClientList(discoveredServers),
                        _buildServerList(connectedClients),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
