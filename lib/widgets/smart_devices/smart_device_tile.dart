import 'package:flutter/material.dart';
import 'package:ghiotta_app/models/smart_device.dart';

class SmartDeviceTile extends StatelessWidget {
  final SmartDevice smartDevice;
  const SmartDeviceTile({super.key, required this.smartDevice});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(smartDevice.name),
      subtitle: Text("node id: ${smartDevice.nodeId}"),
      leading: Icon(
        (smartDevice.attributes["1/6/0"] as bool)
            ? Icons.lightbulb
            : Icons.lightbulb_outline,
      ), // TODO: Make clearer and improve abstraction
      trailing: Icon(switch (smartDevice.available) {
        true => Icons.cloud,
        false => Icons.cloud_off,
      }),
      onTap: () {},
    );
  }
}
