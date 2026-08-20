import 'package:auto_route/auto_route.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/devices.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:ghiotta_app/router.gr.dart';
import 'package:ghiotta_app/widgets/device_tile.dart';
import 'package:ghiotta_app/widgets/scaffold_with_admin_fab.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:talker_flutter/talker_flutter.dart';

final fakeDevices = List.generate(
  10,
  (index) => Device(id: index, name: "", admin: true, enabled: true, token: ""),
);

@RoutePage()
class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DevicesBloc>(
      create: (context) => DevicesBloc(
        talker: context.read<Talker>(),
        api: context.read<ApiRepo>(),
      ),
      child: Builder(
        builder: (context) => ScaffoldWithAdminFab(
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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final NewDevice? newDevice = await AutoRouter.of(context)
                  .parent<StackRouter>()!
                  .push(const AddDeviceRoute());
              if (newDevice != null && context.mounted) {
                context.read<DevicesBloc>().add(
                  DevicesCreate(newDevice: newDevice),
                );
              }
            },
            child: Icon(Icons.add),
          ),
          body: SingleChildScrollView(
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
                      false => BlocSelector<SessionBloc, SessionState, Device?>(
                        selector: (state) => state.device,
                        builder: (context, sessionDevice) => Column(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .stretch,
                          mainAxisSize: .max,
                          children: [
                            for (final device in devices)
                              switch ((sessionDevice?.admin ?? false) &&
                                  sessionDevice?.id != device.id) {
                                true => Dismissible(
                                  background: const ListTile(
                                    leading: Icon(Icons.delete),
                                    trailing: Icon(Icons.delete),
                                  ),
                                  onDismissed: (direction) => context
                                      .read<DevicesBloc>()
                                      .add(DevicesDelete(id: device.id)),
                                  key: ValueKey<int>(device.id),
                                  child: DeviceTile(device: device),
                                ),
                                false => DeviceTile(device: device),
                              },
                          ],
                        ),
                      ),
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
