import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/blocs/settings.dart';
import 'package:ghiotta_app/pages/root/settings.dart';
import 'package:ghiotta_app/router.gr.dart';

@RoutePage()
class RootWrapperPage extends StatelessWidget {
  const RootWrapperPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SessionBloc, SessionState>(
    builder: (context, sessionState) {
      return BlocPresentationListener<SessionBloc, String>(
        listener: (context, error) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(SnackBar(content: Text(error)));
        },
        child: BlocSelector<SettingsBloc, SettingsState, Uri?>(
          selector: (state) => state.apiUrl,
          builder: (context, apiUrl) => switch (apiUrl) {
            null => const SettingsPage(),
            _ => AutoRouter.declarative(
              routes: (handler) {
                return switch ((sessionState.authenticated)) {
                  true => [const DashboardWrapperRoute()],
                  false => [const AuthenticationRoute()],
                };
              },
            ),
          },
        ),
      );
    },
  );
}
