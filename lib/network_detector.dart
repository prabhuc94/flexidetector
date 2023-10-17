/* Author: Prabhu Chandran
* Created On 26/09/2023 08:34 AM */
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkDetector {
  NetworkDetector._() {
    initialize();
  }
  static final NetworkDetector instance = NetworkDetector._();

  final _connectivity = Connectivity();

  String lookUpAddress = "google.com";
  StreamController<NetworkStatus> _controller = StreamController.broadcast(sync: true);
  Stream<NetworkStatus> get networkStream => _controller.stream;

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_checkStatus);
  }

  void _checkStatus(ConnectivityResult result) async {
    var isOnline = false;
    dynamic error;
    try {
      final result = await InternetAddress.lookup(lookUpAddress);
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      isOnline = false;
      error = e;
    }
    if (_controller.isClosed) {
      _controller = StreamController.broadcast(sync: true);
    }
    _controller.sink.add(NetworkStatus(connectionType: result, error: error, internetStatus: isOnline));
  }

  void dispose() {
    _controller.close();
  }
}

class NetworkStatus {
  ConnectivityResult? connectionType;
  bool? internetStatus;
  dynamic error;

  NetworkStatus({this.connectionType, this.internetStatus, this.error});

  Map<String, dynamic> toJson() => {
    "connectionType" : connectionType,
    "internetStatus" : internetStatus,
    "error" : error
  };
}

final networkDetector = NetworkDetector.instance;