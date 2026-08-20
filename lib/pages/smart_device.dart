import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/session.dart';
import 'package:ghiotta_app/blocs/smart_device.dart';
import 'package:ghiotta_app/blocs/smart_devices.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:ghiotta_app/repos/api.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class SmartDevicePage extends StatelessWidget {
  final SmartDevice smartDevice;
  const SmartDevicePage({super.key, required this.smartDevice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SmartDeviceBloc(
        talker: context.read<Talker>(),
        api: context.read<ApiRepo>(),
        device: smartDevice,
      ),
      child: Builder(
        builder: (context) => BlocSelector<SessionBloc, SessionState, bool>(
          selector: (state) => state.device?.admin ?? false,
          builder: (context, admin) => Scaffold(
            appBar: AppBar(
              title: Text(smartDevice.name),
              centerTitle: false,
              actions: [
                if (admin)
                  IconButton(
                    onPressed: () async {
                      context.read<SmartDevicesBloc>().add(
                        SmartDevicesDelete(nodeId: smartDevice.nodeId),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.delete),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child:
                    BlocSelector<
                      SmartDeviceBloc,
                      SmartDeviceState,
                      SmartDevice
                    >(
                      selector: (state) => state.device,
                      builder: (context, device) => Column(
                        mainAxisAlignment: .start,
                        crossAxisAlignment: .center,
                        children: [
                          device.icon(size: 100),
                          SizedBox(height: 48),
                          if (device.hasCluster(MatterCluster.onOff))
                            SwitchListTile(
                              title: const Text("On/Off"),
                              value: device.on ?? false,
                              onChanged: (value) => context
                                  .read<SmartDeviceBloc>()
                                  .add(SmartDeviceSetOnOff(value: value)),
                            ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
