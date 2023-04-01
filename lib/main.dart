import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:socket_app/models/clients_model.dart';
import 'package:socket_app/screens/home_page.dart';
import 'package:socket_app/web_socket/web_socket_server.dart';

void main() async {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  runApp(
    MyApp(scaffoldKey: scaffoldKey),
  );
  await Permission.location.request();
  final info = NetworkInfo();
  var hostAddress = await info.getWifiIP();
  print(hostAddress);

  runApp(
    MyApp(scaffoldKey: scaffoldKey),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MyApp({required this.scaffoldKey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientsModel(),
      builder: (context, child) {
        final clientsModel = Provider.of<ClientsModel>(context, listen: false);
        final webSocketServer = WebSocketServer();
        webSocketServer.start("127.0.0.1", 8080, clientsModel: clientsModel);

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomePage(scaffoldKey: scaffoldKey),
        );
      },
    );
  }
}
