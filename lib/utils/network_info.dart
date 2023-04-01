import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<String?> getWifiIPAddress() async {
    return await _networkInfo.getWifiIP();
  }
}
