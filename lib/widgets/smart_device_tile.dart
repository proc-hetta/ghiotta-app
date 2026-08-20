import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:ghiotta_app/router.gr.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SmartDeviceTile extends StatelessWidget {
  final SmartDevice smartDevice;
  const SmartDeviceTile({super.key, required this.smartDevice});

  @override
  Widget build(BuildContext context) {
    context.read<Talker>().debug(
      "ATTRIBUTE: ${smartDevice.attributes["1/29/0"]}",
    );
    return ListTile(
      title: Text(smartDevice.name),
      subtitle: Text("node id: ${smartDevice.nodeId}"),
      leading: smartDevice.icon(),
      trailing: Icon(switch (smartDevice.available) {
        true => Icons.cloud,
        false => Icons.cloud_off,
      }),
      onTap: () =>
          AutoRouter.of(context)
              .parent<StackRouter>()!
              .push(SmartDeviceRoute(smartDevice: smartDevice)),
    );
  }
}
