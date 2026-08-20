import 'package:auto_route/auto_route.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/devices.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:ghiotta_app/router.gr.dart';
import 'package:ghiotta_app/widgets/smart_devices/device_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:talker_flutter/talker_flutter.dart';

final fakeDevice = Device(
  id: -1,
  name: "",
  admin: true,
  enabled: true,
  token: "",
);
final fakeDevices = List.filled(10, fakeDevice);

@RoutePage()
class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Authorized devices"),
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
        child: BlocProvider<DevicesBloc>(
          create: (context) => DevicesBloc(
            talker: context.read<Talker>(),
            api: context.read<ApiRepo>(),
          ),
          child: BlocPresentationListener<DevicesBloc, String>(
            listener: (context, error) {
              final messenger = ScaffoldMessenger.of(context);
              messenger.clearSnackBars();
              messenger.showSnackBar(SnackBar(content: Text(error)));
            },
            child: BlocBuilder<DevicesBloc, DevicesState>(
              builder: (context, smartDevicesState) {
                final devices = smartDevicesState.status == .loading
                    ? fakeDevices
                    : smartDevicesState.devices;
                return Skeletonizer(
                  enabled: smartDevicesState.status == .loading,
                  child: switch (devices.isEmpty) {
                    true => Center(child: const Text("No devices found...")),
                    false => Column(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .stretch,
                      mainAxisSize: .max,
                      children: [
                        for (final device in devices)
                          DeviceTile(device: device),
                      ],
                    ),
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
