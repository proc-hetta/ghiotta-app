import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'settings.freezed.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

class _SettingsInit extends SettingsEvent {
  const _SettingsInit();
}

@freezed
abstract class SettingsUpdate extends SettingsEvent with _$SettingsUpdate {
  const SettingsUpdate._();
  const factory SettingsUpdate({required Uri apiUrl}) = _SettingsUpdate;
}

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({required Uri? apiUrl}) = _SettingsState;
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Talker talker;
  final ApiRepo api;

  SettingsBloc({required this.talker, required this.api})
    : super(SettingsState(apiUrl: api.apiUrl)) {
    on<_SettingsInit>(_onSettingsInit, transformer: droppable());
    on<SettingsUpdate>(_onSettingsUpdate, transformer: restartable());
    add(const _SettingsInit());
  }

  Future<void> _onSettingsInit(
    _SettingsInit event,
    Emitter<SettingsState> emit,
  ) async {
    await emit.forEach(
      api.apiUrlStream,
      onData: (apiUrl) => state.copyWith(apiUrl: apiUrl),
    );
  }

  Future<void> _onSettingsUpdate(
    SettingsUpdate event,
    Emitter<SettingsState> emit,
  ) async {
    await api.setApiUrl(event.apiUrl);
  }
}
