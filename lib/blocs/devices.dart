import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'devices.freezed.dart';

enum DevicesStatus { idle, loading, error }

sealed class DevicesEvent {
  const DevicesEvent();
}

class _DevicesInit extends DevicesEvent {
  const _DevicesInit();
}

@freezed
abstract class DevicesFetch extends DevicesEvent with _$DevicesFetch {
  const DevicesFetch._();
  const factory DevicesFetch({
    @Default(Duration.zero) Duration emitAfter,
    @Default(false) bool showLoading,
  }) = _DevicesFetch;
}

@freezed
abstract class DevicesCreate extends DevicesEvent with _$DevicesCreate {
  const DevicesCreate._();
  const factory DevicesCreate({required NewDevice newDevice}) = _DevicesCreate;
}

@freezed
abstract class DevicesDelete extends DevicesEvent with _$DevicesDelete {
  const DevicesDelete._();
  const factory DevicesDelete({required int id}) = _DevicesDelete;
}

@freezed
abstract class DevicesState with _$DevicesState {
  const factory DevicesState({
    required List<Device> devices,
    required DevicesStatus status,
  }) = _DevicesState;
}

class DevicesBloc extends Bloc<DevicesEvent, DevicesState>
    with BlocPresentationMixin<DevicesState, String> {
  final Talker talker;
  final ApiRepo api;

  Timer? _refreshTimer;
  final BehaviorSubject<List<Device>> _refreshQueue;

  DevicesBloc({required this.talker, required this.api})
    : _refreshQueue = BehaviorSubject(),
      super(const DevicesState(devices: [], status: .loading)) {
    on<_DevicesInit>(_onDevicesInit, transformer: droppable());
    on<DevicesFetch>(_onDevicesFetch, transformer: restartable());
    on<DevicesCreate>(_onDevicesCreate, transformer: droppable());
    on<DevicesDelete>(_onDevicesDelete, transformer: droppable());
    add(const _DevicesInit());
    add(
      const DevicesFetch(
        showLoading: true,
        emitAfter: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    await super.close();
  }

  Future<void> _onDevicesInit(
    _DevicesInit event,
    Emitter<DevicesState> emit,
  ) async {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      _onRefreshTimerTick,
    );
    await emit.forEach(
      _refreshQueue,
      onData: (devices) => state.copyWith(devices: devices),
    );
  }

  Future<void> _onDevicesFetch(
    DevicesFetch event,
    Emitter<DevicesState> emit,
  ) async {
    if (event.showLoading) {
      emit(state.copyWith(status: .loading));
    }
    emit(
      state.copyWith(
        status: await _devicesFetch(event.emitAfter) ? .idle : .error,
      ),
    );
  }

  Future<void> _onDevicesCreate(
    DevicesCreate event,
    Emitter<DevicesState> emit,
  ) async {
    try {
      await api.client.createDevice(event.newDevice);
    } on DioException catch (s, t) {
      talker.handle(s, t);
      emitPresentation("Network error: ${s.response?.statusCode ?? "Unknown"}");
      return;
    }
  }

  Future<void> _onDevicesDelete(
    DevicesDelete event,
    Emitter<DevicesState> emit,
  ) async {
    try {
      await api.client.deleteDevice(event.id);
    } on DioException catch (s, t) {
      talker.handle(s, t);
      emitPresentation("Network error: ${s.response?.statusCode ?? "Unknown"}");
      return;
    }
  }

  Future<bool> _devicesFetch(Duration emitAfter) async {
    final List<Device> devices;
    try {
      [devices, _] = await Future.wait([
        api.client.getDevices(),
        Future.delayed(emitAfter, () => []),
      ]);
    } on DioException catch (s, t) {
      talker.handle(s, t);
      if (s.response?.statusCode != null && s.response?.statusCode != 401) {
        emitPresentation(
          "Network error: ${s.response?.statusCode ?? "Unknown"}",
        );
      }
      return false;
    }
    _refreshQueue.add(devices);
    return true;
  }

  Future<void> _onRefreshTimerTick(Timer timer) {
    talker.debug("refreshing... TICK ${timer.tick}");
    return _devicesFetch(Duration.zero);
  }
}
