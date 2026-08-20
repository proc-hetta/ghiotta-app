import 'dart:async';

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

sealed class SessionEvent {
  const SessionEvent();
}

class _SessionInit extends SessionEvent {
  const _SessionInit();
}

@freezed
abstract class SessionRefresh extends SessionEvent with _$SessionRefresh {
  const SessionRefresh._();
  const factory SessionRefresh({@Default(Duration.zero) Duration emitAfter}) =
      _SessionRefresh;
}

@freezed
abstract class SessionState with _$SessionState {
  const factory SessionState({
    required bool authenticated,
    required String token,
    required Device? device,
  }) = _SessionState;
}

class SessionBloc extends Bloc<SessionEvent, SessionState>
    with BlocPresentationMixin<SessionState, String> {
  final Talker talker;
  final ApiRepo api;

  Timer? _refreshTimer;

  SessionBloc({required this.talker, required this.api})
    : super(
        SessionState(
          authenticated: api.authenticated,
          device: null,
          token: api.apiToken,
        ),
      ) {
    on<_SessionInit>(_onSessionInit, transformer: droppable());
    on<SessionRefresh>(_onSessionRefresh, transformer: restartable());
    add(const _SessionInit());
    add(const SessionRefresh(emitAfter: Duration(milliseconds: 500)));
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    await super.close();
  }

  Future<void> _onSessionInit(
    _SessionInit event,
    Emitter<SessionState> emit,
  ) async {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _onRefreshTimerTick(timer, emit),
    );
    await emit.forEach(
      api.authenticatedStream,
      onData: (value) => state.copyWith(authenticated: value),
    );
  }

  Future<void> _onSessionRefresh(
    SessionRefresh event,
    Emitter<SessionState> emit,
  ) => _refreshDevice(event.emitAfter, emit);

  Future<void> _refreshDevice(
    Duration emitAfter,
    Emitter<SessionState> emit,
  ) async {
    final Device? device;
    try {
      [device, _] = await Future.wait([
        api.client.getAuthenticatedDevice(),
        Future.delayed(emitAfter, () => null),
      ]);
    } on DioException catch (s, t) {
      talker.handle(s, t);
      if (s.response?.statusCode != null && s.response?.statusCode != 401) {
        emitPresentation(
          "Network error: ${s.response?.statusCode ?? "Unknown"}",
        );
      }
      return;
    }
    api.setAuthenticated(true);
    emit(state.copyWith(device: device));
  }

  Future<void> _onRefreshTimerTick(Timer timer, Emitter<SessionState> emit) {
    talker.debug("refreshing... TICK ${timer.tick}");
    return _refreshDevice(Duration.zero, emit);
  }
}
