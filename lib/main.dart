import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([.portraitUp]);
  final talker = TalkerFlutter.init(
    logger: TalkerLogger(filter: LogLevelFilter(.debug)),
    settings: TalkerSettings(
      enabled: true,
      useHistory: true,
      maxHistoryItems: 10000,
      useConsoleLogs: true,
      timeFormat: .yearMonthDayAndTime,
    ),
  );
  Bloc.observer = TalkerBlocObserver();
  final packageInfo = await PackageInfo.fromPlatform();
  talker.info(
    "*** Ghiotta APP ${packageInfo.version} ***\n"
    "Package info:\n"
    "  appName: ${packageInfo.appName}\n"
    "  packageName: ${packageInfo.packageName}\n"
    "  version: ${packageInfo.version}\n"
    "  buildNumber: ${packageInfo.buildNumber}",
  );
  final sharedPreferences = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );

  talker.info("Preloading finished");
  talker.info("Executing main app");
  runApp(
    GhiottaApp(
      talker: talker,
      packageInfo: packageInfo,
      sharedPreferences: sharedPreferences,
    ),
  );
}
