import 'package:auto_route/auto_route.dart';
import 'package:ghiotta_app/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const .material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      page: RootStackRoute.page,
      children: [
        AutoRoute(
          initial: true,
          page: RootWrapperRoute.page,
          children: [
            AutoRoute(page: AuthenticationRoute.page),
            AutoRoute(
              page: DashboardWrapperRoute.page,
              children: [
                AutoRoute(page: SettingsRoute.page),
                AutoRoute(page: SmartDevicesRoute.page),
                AutoRoute(page: DevicesRoute.page),
              ],
            ),
          ],
        ),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: AddDeviceRoute.page),
        AutoRoute(page: SmartDeviceRoute.page),
      ],
    ),
  ];
}
