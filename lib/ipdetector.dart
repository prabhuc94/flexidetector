import 'dart:convert';
import 'package:http/http.dart' as http;

class IpDetector {
  static final IpDetector instance = IpDetector._internal();
  factory IpDetector()=> instance;
  IpDetector._internal();

  Future<String?> detect({String? url}) async {
    if (url == null || url.isEmpty) {
      return await _detectAPI();
    }
    return await _detectByURL(url);
  }

  Future<String?> _detectByURL(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch(e) {
      return null;
    }
  }

  Future<String?> _detectAPI() async {
    var url = Uri.https("worldtimeapi.org", "/api/ip");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = Map.from(jsonDecode(response.body));
        return decodedResponse.containsKey("client_ip") ? "${decodedResponse['client_ip']}" : response.body;
      } else {
        return null;
      }
    } catch(e) {
      return null;
    }
  }
}