import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/router.gr.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage()
class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Authentication"),
        actions: [
          IconButton(
            onPressed: () =>
                AutoRouter.of(context)
                    .parent<StackRouter>()!
                    .push(SettingsRoute()),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: BlocSelector<SessionBloc, SessionState, String>(
        selector: (state) => state.token,
        builder: (context, token) => Center(
          child: Column(
            mainAxisAlignment: .center,
            mainAxisSize: .max,
            crossAxisAlignment: .center,
            children: [
              Text(
                "Show to admins",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              QrImageView(data: token, size: 320, gapless: true),
            ],
          ),
        ),
      ),
    );
  }
}
