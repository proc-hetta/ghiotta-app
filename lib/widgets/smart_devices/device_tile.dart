import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/models/device.dart';

class DeviceTile extends StatelessWidget {
  final Device device;
  const DeviceTile({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name),
      subtitle: Text("id: ${device.id}"),
      leading: Icon(switch (device.admin) {
        true => Icons.security,
        false => Icons.person,
      }),
      trailing: Icon(switch (device.enabled) {
        true => Icons.check_circle,
        false => Icons.block,
      }),
      onTap: (context.watch<SessionBloc>().state.device?.id ?? -1) == device.id
          ? null
          : () {},
    );
  }
}
