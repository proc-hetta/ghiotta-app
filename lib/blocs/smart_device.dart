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

part 'smart_device.freezed.dart';

sealed class SmartDeviceEvent {
  const SmartDeviceEvent();
}

class _SmartDeviceInit extends SmartDeviceEvent {
  const _SmartDeviceInit();
}

@freezed
abstract class SmartDeviceFetch extends SmartDeviceEvent
    with _$SmartDeviceFetch {
  const SmartDeviceFetch._();
  const factory SmartDeviceFetch({@Default(Duration.zero) Duration emitAfter}) =
      _SmartDeviceFetch;
}

@freezed
abstract class SmartDeviceSetOnOff extends SmartDeviceEvent
    with _$SmartDeviceSetOnOff {
  const SmartDeviceSetOnOff._();
  const factory SmartDeviceSetOnOff({required bool value}) =
      _SmartDeviceSetOnOff;
}

@freezed
abstract class SmartDeviceState with _$SmartDeviceState {
  const factory SmartDeviceState({required SmartDevice device}) =
      _SmartDeviceState;
}

class SmartDeviceBloc extends Bloc<SmartDeviceEvent, SmartDeviceState>
    with BlocPresentationMixin<SmartDeviceState, String> {
  final Talker talker;
  final ApiRepo api;
  final SmartDevice device;

  Timer? _refreshTimer;
  final BehaviorSubject<SmartDevice> _refreshQueue;

  SmartDeviceBloc({
    required this.talker,
    required this.api,
    required this.device,
  }) : _refreshQueue = BehaviorSubject(),
       super(SmartDeviceState(device: device)) {
    on<_SmartDeviceInit>(_onSmartDeviceInit, transformer: droppable());
    on<SmartDeviceFetch>(_onSmartDeviceFetch, transformer: restartable());
    on<SmartDeviceSetOnOff>(_onSmartDeviceSetOnOff, transformer: restartable());
    add(const _SmartDeviceInit());
    add(const SmartDeviceFetch(emitAfter: Duration(milliseconds: 500)));
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    await super.close();
  }

  Future<void> _onSmartDeviceInit(
    _SmartDeviceInit event,
    Emitter<SmartDeviceState> emit,
  ) async {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      _onRefreshTimerTick,
    );
    await emit.forEach(
      _refreshQueue,
      onData: (device) => state.copyWith(device: device),
    );
  }

  Future<void> _onSmartDeviceFetch(
    SmartDeviceFetch event,
    Emitter<SmartDeviceState> emit,
  ) => _smartDevicesFetch(event.emitAfter);

  Future<bool> _smartDevicesFetch(Duration emitAfter) async {
    final SmartDevice device;
    try {
      [device, _] = await Future.wait([
        api.client.getSmartDevice(this.device.nodeId),
        Future.delayed(emitAfter, () => this.device),
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
    _refreshQueue.add(device);
    return true;
  }

  Future<void> _onSmartDeviceSetOnOff(
    SmartDeviceSetOnOff event,
    Emitter<SmartDeviceState> emit,
  ) async {
    try {
      await api.client.toggle(device.nodeId);
    } on DioException catch (s, t) {
      talker.handle(s, t);
      emitPresentation("Network error: ${s.response?.statusCode ?? "Unknown"}");
    }
  }

  Future<void> _onRefreshTimerTick(Timer timer) {
    talker.debug("refreshing... TICK ${timer.tick}");
    return _smartDevicesFetch(Duration.zero);
  }
}
