import 'package:auto_route/auto_route.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/blocs/smart_devices.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:ghiotta_app/router.gr.dart';
import 'package:ghiotta_app/widgets/scaffold_with_admin_fab.dart';
import 'package:ghiotta_app/widgets/smart_device_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

final fakeDevices = List.generate(
  10,
  (index) => SmartDevice(
    nodeId: index,
    name: "",
    dateCommissioned: DateTime.now(),
    lastInterview: DateTime.now(),
    interviewVersion: 1,
    available: true,
    isBridge: true,
    attributes: {},
    attributeSubscriptions: [],
    matterVersion: "",
  ),
);

@RoutePage()
class SmartDevicesPage extends StatelessWidget {
  const SmartDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithAdminFab(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final SmartDeviceCommission? smartDeviceCommission =
              await AutoRouter.of(context)
                  .parent<StackRouter>()!
                  .push(const AddDeviceRoute());
          if (smartDeviceCommission != null && context.mounted) {
            context.read<SmartDevicesBloc>().add(
              SmartDevicesCreate(smartDeviceCommission: smartDeviceCommission),
            );
          }
        },
        child: Icon(Icons.add),
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
                  false => BlocSelector<SessionBloc, SessionState, Device?>(
                    selector: (state) => state.device,
                    builder: (context, sessionDevice) => Column(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .stretch,
                      mainAxisSize: .max,
                      children: [
                        for (final device in devices)
                          switch (sessionDevice?.admin ?? false) {
                            true => Dismissible(
                              background: const ListTile(
                                leading: Icon(Icons.delete),
                                trailing: Icon(Icons.delete),
                              ),
                              onDismissed: (direction) =>
                                  context.read<SmartDevicesBloc>().add(
                                    SmartDevicesDelete(nodeId: device.nodeId),
                                  ),
                              key: ValueKey<int>(device.nodeId),
                              child: SmartDeviceTile(smartDevice: device),
                            ),
                            false => SmartDeviceTile(smartDevice: device),
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
    );
  }
}
