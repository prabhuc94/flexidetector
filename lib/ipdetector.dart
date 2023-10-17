import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IpDetector {
  IpDetector._();
  static final IpDetector instance = IpDetector._();

  Future<String> localIp({InternetAddressType type = InternetAddressType.IPv4}) async {
    var addresses = await InternetAddress.lookup(Platform.localHostname);
    return "${addresses.where((element) => element.type == type).map((e) => e.address).firstOrNull}";
  }

  Future<String?> detect({String? url}) async {
    if (url == null || url.isEmpty) {
      return await compute(_detectAPI, null);
    }
    return await compute(_detectByURL, url);
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

  Future<String?> _detectAPI(_) async {
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

final ipDetector = IpDetector.instance;