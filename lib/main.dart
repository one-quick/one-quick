import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/models/clients_model.dart';
import 'package:socket_app/screens/home_page.dart';
import 'package:socket_app/web_socket/web_socket_server.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientsModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder<String>(
          future: _getHostAddress(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final clientsModel =
                  Provider.of<ClientsModel>(context, listen: false);
              final webSocketServer = WebSocketServer();
              webSocketServer.start("0.0.0.0", 8080,
                  clientsModel: clientsModel);
              return HomePage(scaffoldKey: scaffoldKey);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            } else {
              return _buildLoadingWidget();
            }
          },
        ),
      ),
    );
  }

  Future<String> _getHostAddress() async {
    await Permission.location.request();
    final info = NetworkInfo();
    return await info.getWifiIP() ?? "0.0.0.0";
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text("Error: $error"),
    );
  }
}
