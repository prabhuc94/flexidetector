import 'package:flexidetector/enumeration.dart';

class AlertDetectionModel {
  ActivityStatus? status;
  int? minute;

  AlertDetectionModel({this.status, this.minute});

  factory AlertDetectionModel.fromJson(Map<String, dynamic> json) => AlertDetectionModel(status: ActivityStatus.values.where((element) => element.name == "${json['status']}").firstOrNull, minute: json['minute']);

  Map<String, dynamic> toJson() => {
    "status" : status?.name,
    "minute" : minute
  };

}