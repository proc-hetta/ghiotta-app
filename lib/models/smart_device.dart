import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'smart_device.freezed.dart';
part 'smart_device.g.dart';

abstract final class MatterCluster {
  static const int descriptor = 0x001D;
  static const int identify = 0x0003;
  static const int groups = 0x0004;
  static const int onOff = 0x0006;
  static const int levelControl = 0x0008;
  static const int colorControl = 0x0300;
  static const int temperatureMeasurement = 0x0402;
  static const int humidityMeasurement = 0x0405;
  static const int occupancySensing = 0x0406;
  static const int thermostat = 0x0201;
}

@freezed
abstract class SmartDeviceCommission with _$SmartDeviceCommission {
  const SmartDeviceCommission._();
  const factory SmartDeviceCommission({
    required String name,
    required String code,
    @JsonKey(name: "network_only") @Default(true) bool networkOnly,
  }) = _SmartDeviceCommission;

  factory SmartDeviceCommission.fromJson(Map<String, Object?> json) =>
      _$SmartDeviceCommissionFromJson(json);
}

@freezed
abstract class SmartDevice with _$SmartDevice {
  const SmartDevice._();
  const factory SmartDevice({
    @JsonKey(name: "node_id") required int nodeId,
    required String name,
    @JsonKey(name: "date_commissioned") required DateTime dateCommissioned,
    @JsonKey(name: "last_interview") required DateTime lastInterview,
    @JsonKey(name: "interview_version") required int interviewVersion,
    required bool available,
    @JsonKey(name: "is_bridge") required bool isBridge,
    required Map<String, dynamic> attributes,
    @JsonKey(name: "attribute_subscriptions")
    required List<int> attributeSubscriptions,
    @JsonKey(name: "matter_version") required String matterVersion,
  }) = _SmartDevice;

  factory SmartDevice.fromJson(Map<String, Object?> json) =>
      _$SmartDeviceFromJson(json);

  Icon icon({double? size}) {
    return Icon(switch (attributes["1/29/0"]?[0]?["0"]) {
      0x0100 || 0x0101 || 0x0102 || 0x0105 || 0x010D =>
        (attributes["1/6/0"] as bool?) ?? false
            ? Icons.lightbulb
            : Icons.lightbulb_outlined,
      0x010A =>
        (attributes["1/6/0"] as bool?) ?? false
            ? Icons.toggle_on
            : Icons.toggle_off_outlined,
      _ => Icons.question_mark,
    }, size: size);
  }

  bool hasCluster(int cluster) {
    final clusters = (attributes["1/29/1"] as List?)?.whereType<int>().toList();
    return clusters?.contains(cluster) ?? false;
  }

  dynamic _attribute(int clusterId, int attributeId) {
    return attributes['1/$clusterId/$attributeId'];
  }

  bool? get on {
    final value = _attribute(0x0006, 0x0000);
    return value is bool ? value : null;
  }
}
