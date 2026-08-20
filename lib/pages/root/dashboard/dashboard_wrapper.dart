import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/router.gr.dart';

@RoutePage()
class DashboardWrapperPage extends StatelessWidget {
  const DashboardWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [const SmartDevicesRoute(), const DevicesRoute()],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) {
            if (index != tabsRouter.activeIndex) {
              FocusScope.of(context).unfocus();
            }
            tabsRouter.setActiveIndex(index);
          },
          destinations: [
            NavigationDestination(icon: Icon(Icons.device_hub), label: "Hub"),
            BlocSelector<SessionBloc, SessionState, bool>(
              selector: (state) => state.device?.admin ?? false,
              builder: (context, admin) => NavigationDestination(
                icon: Icon(Icons.manage_accounts),
                label: "Authorizations",
                enabled: admin,
              ),
            ),
          ],
        );
      },
    );
  }
}
