import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';

class ScaffoldWithAdminFab extends StatelessWidget {
  final FloatingActionButton? floatingActionButton;
  final Widget body;
  final AppBar? appBar;
  const ScaffoldWithAdminFab({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SessionBloc, SessionState, bool>(
      selector: (state) => state.device?.admin ?? false,
      builder: (context, admin) => Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: admin ? floatingActionButton : null,
      ),
    );
  }
}
