import 'package:dio/dio.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api.freezed.dart';
part 'api.g.dart';

@freezed
abstract class SmartDevicesList with _$SmartDevicesList {
  const SmartDevicesList._();
  const factory SmartDevicesList({
    @JsonKey(name: "connected_nodes") required List<SmartDevice> connectedNodes,
  }) = _SmartDevicesList;

  factory SmartDevicesList.fromJson(Map<String, Object?> json) =>
      _$SmartDevicesListFromJson(json);
}

@RestApi(headers: {"Content-Type": "application/json"})
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/v1/self")
  Future<Device> getAuthenticatedDevice();

  @GET("/api/v1/smart-devices")
  Future<SmartDevicesList> _getSmartDevices();

  @GET("/api/v1/admin/authorized-devices")
  Future<List<Device>> getDevices();
}

extension ApiExtension on ApiClient {
  Future<List<SmartDevice>> getSmartDevices() async {
    return (await _getSmartDevices()).connectedNodes;
  }
}

class ApiRepo {
  final Talker talker;
  final Dio dio;
  ApiClient client;
  final SharedPreferencesWithCache sharedPreferences;

  final BehaviorSubject<Uri?> _apiUrlStreamController;
  ValueStream<Uri?> get apiUrlStream => _apiUrlStreamController.stream;
  Uri? get apiUrl => apiUrlStream.value;
  static const String apiUrlPreference = "apiUrl";

  final BehaviorSubject<String> _apiTokenStreamController;
  ValueStream<String> get apiTokenStream => _apiTokenStreamController.stream;
  String get apiToken => apiTokenStream.value;
  static const String apiTokenPreference = "apiToken";

  final BehaviorSubject<bool> _authenticatedStreamController;
  ValueStream<bool> get authenticatedStream =>
      _authenticatedStreamController.stream;
  bool get authenticated => authenticatedStream.value;

  ApiRepo({
    required this.talker,
    required this.dio,
    required this.sharedPreferences,
  }) : _apiUrlStreamController = BehaviorSubject<Uri?>.seeded(
         _getApiUrl(sharedPreferences),
       ),
       _apiTokenStreamController = BehaviorSubject<String>.seeded(
         _getApiToken(sharedPreferences),
       ),
       _authenticatedStreamController = BehaviorSubject<bool>.seeded(true),
       client = ApiClient(
         dio,
         baseUrl: _getApiUrl(sharedPreferences)?.toString(),
       ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.putIfAbsent(
            "Authorization",
            () => "BEARER $apiToken",
          );
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            talker.warning(
              "Received 401 from endpoint `${error.requestOptions.method} ${error.requestOptions.path}`. Setting authenticated to `false`...",
            );
            setAuthenticated(false);
          }
          handler.next(error);
        },
      ),
    );
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
          printResponseData: false,
        ),
      ),
    );
  }

  Future<void> logOut() => sharedPreferences.remove(apiTokenPreference);

  static Uri? _getApiUrl(SharedPreferencesWithCache sharedPreferences) {
    final apiUrl = sharedPreferences.getString(apiUrlPreference);
    return apiUrl == null ? null : Uri.tryParse(apiUrl);
  }

  static String _getApiToken(SharedPreferencesWithCache sharedPreferences) {
    var apiToken = sharedPreferences.getString(apiTokenPreference);
    if (apiToken == null) {
      apiToken = Uuid().v4();
      sharedPreferences.setString(apiTokenPreference, apiToken);
    }
    return apiToken;
  }

  Future<void> setApiUrl(Uri apiUrl) async {
    await sharedPreferences.setString(apiUrlPreference, apiUrl.toString());
    client = ApiClient(dio, baseUrl: apiUrl.toString());
    _apiUrlStreamController.add(apiUrl);
  }

  void setAuthenticated(bool value) {
    _authenticatedStreamController.add(value);
  }
}
