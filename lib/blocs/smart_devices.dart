import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'smart_devices.freezed.dart';

enum SmartDevicesStatus { idle, loading, error }

sealed class SmartDevicesEvent {
  const SmartDevicesEvent();
}

class _SmartDevicesInit extends SmartDevicesEvent {
  const _SmartDevicesInit();
}

@freezed
abstract class SmartDevicesFetch extends SmartDevicesEvent
    with _$SmartDevicesFetch {
  const SmartDevicesFetch._();
  const factory SmartDevicesFetch({
    @Default(Duration.zero) Duration emitAfter,
    @Default(false) bool showLoading,
  }) = _SmartDevicesFetch;
}

@freezed
abstract class SmartDevicesState with _$SmartDevicesState {
  const factory SmartDevicesState({
    required List<SmartDevice> devices,
    required SmartDevicesStatus status,
  }) = _SmartDevicesState;
}

class SmartDevicesBloc extends Bloc<SmartDevicesEvent, SmartDevicesState>
    with BlocPresentationMixin<SmartDevicesState, String> {
  final Talker talker;
  final ApiRepo api;

  Timer? _refreshTimer;
  final BehaviorSubject<List<SmartDevice>> _refreshQueue;

  SmartDevicesBloc({required this.talker, required this.api})
    : _refreshQueue = BehaviorSubject(),
      super(const SmartDevicesState(devices: [], status: .loading)) {
    on<_SmartDevicesInit>(_onSmartDevicesInit, transformer: droppable());
    on<SmartDevicesFetch>(_onSmartDevicesFetch, transformer: restartable());
    add(const _SmartDevicesInit());
    add(
      const SmartDevicesFetch(
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

  Future<void> _onSmartDevicesInit(
    _SmartDevicesInit event,
    Emitter<SmartDevicesState> emit,
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

  Future<void> _onSmartDevicesFetch(
    SmartDevicesFetch event,
    Emitter<SmartDevicesState> emit,
  ) async {
    if (event.showLoading) {
      emit(state.copyWith(status: .loading));
    }
    emit(
      state.copyWith(
        status: await _smartDevicesFetch(event.emitAfter) ? .idle : .error,
      ),
    );
  }

  Future<bool> _smartDevicesFetch(Duration emitAfter) async {
    final List<SmartDevice> devices;
    try {
      [devices, _] = await Future.wait([
        api.client.getSmartDevices(),
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
    return _smartDevicesFetch(Duration.zero);
  }
}
