import 'package:auto_route/auto_route.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/smart_devices.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:ghiotta_app/router.gr.dart';
import 'package:ghiotta_app/widgets/smart_devices/smart_device_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

final fakeDevice = SmartDevice(
  nodeId: 1,
  name: "",
  dateCommissioned: DateTime.now(),
  lastInterview: DateTime.now(),
  interviewVersion: 1,
  available: true,
  isBridge: true,
  attributes: {},
  attributeSubscriptions: [],
  matterVersion: "",
);
final fakeDevices = List.filled(10, fakeDevice);

@RoutePage()
class SmartDevicesPage extends StatelessWidget {
  const SmartDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart devices"),
        centerTitle: false,
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
      body: SingleChildScrollView(
        child: BlocPresentationListener<SmartDevicesBloc, String>(
          listener: (context, error) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(SnackBar(content: Text(error)));
          },
          child: BlocBuilder<SmartDevicesBloc, SmartDevicesState>(
            builder: (context, smartDevicesState) {
              final devices = smartDevicesState.status == .loading
                  ? fakeDevices
                  : smartDevicesState.devices;
              return Skeletonizer(
                enabled: smartDevicesState.status == .loading,
                child: switch (devices.isEmpty) {
                  true => Center(
                    child: const Text("No smart devices found..."),
                  ),
                  false => Column(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .stretch,
                    mainAxisSize: .max,
                    children: [
                      for (final device in devices)
                        SmartDeviceTile(smartDevice: device),
                    ],
                  ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
