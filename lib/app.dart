import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/blocs/settings.dart';
import 'package:ghiotta_app/blocs/smart_devices.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:ghiotta_app/router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

class GhiottaApp extends StatelessWidget {
  final _router = AppRouter();

  final Talker talker;
  final PackageInfo packageInfo;
  final SharedPreferencesWithCache sharedPreferences;

  GhiottaApp({
    super.key,
    required this.talker,
    required this.packageInfo,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Talker>.value(value: talker),
        Provider<PackageInfo>.value(value: packageInfo),
        Provider<ApiRepo>(
          create: (_) {
            return ApiRepo(
              talker: talker,
              sharedPreferences: sharedPreferences,
              dio: Dio(BaseOptions(connectTimeout: const Duration(seconds: 5))),
            );
          },
        ),
        BlocProvider<SessionBloc>(
          create: (context) => SessionBloc(
            talker: context.read<Talker>(),
            api: context.read<ApiRepo>(),
          ),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            talker: context.read<Talker>(),
            api: context.read<ApiRepo>(),
          ),
        ),
        BlocProvider<SmartDevicesBloc>(
          create: (context) => SmartDevicesBloc(
            talker: context.read<Talker>(),
            api: context.read<ApiRepo>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ghiotta',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        routerConfig: _router.config(
          navigatorObservers: () => [TalkerRouteObserver(talker)],
        ),
      ),
    );
  }
}
