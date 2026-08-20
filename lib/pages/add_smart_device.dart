import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ghiotta_app/models/smart_device.dart';
import 'package:ghiotta_app/widgets/qr.dart';

@RoutePage()
class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) => QrView(
    validate: (token) => true,
    formBuilder: (context, token) => _NewSmartDeviceForm(token: token),
  );
}

class _NewSmartDeviceForm extends StatefulWidget {
  final String token;
  const _NewSmartDeviceForm({required this.token});

  @override
  State<StatefulWidget> createState() => _NewSmartDeviceFormState();
}

class _NewSmartDeviceFormState extends State<_NewSmartDeviceForm> {
  late final TextEditingController _nameController;
  bool admin = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: .max,
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          spacing: 12,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(label: Text("Name")),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: .end,
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    SmartDeviceCommission(
                      name: _nameController.text,
                      code: widget.token,
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
