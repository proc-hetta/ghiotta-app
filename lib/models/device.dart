import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
abstract class NewDevice with _$NewDevice {
  const factory NewDevice({
    required String name,
    required bool admin,
    required String token,
    required bool enabled,
  }) = _NewDevice;

  factory NewDevice.fromJson(Map<String, Object?> json) =>
      _$NewDeviceFromJson(json);
}

@freezed
abstract class Device with _$Device {
  const factory Device({
    required int id,
    required String name,
    required bool admin,
    required String token,
    required bool enabled,
  }) = _Device;

  factory Device.fromJson(Map<String, Object?> json) => _$DeviceFromJson(json);
}
