import 'package:freezed_annotation/freezed_annotation.dart';

part 'smart_device.freezed.dart';
part 'smart_device.g.dart';

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
}
