import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ghiotta_app/models/device.dart';
import 'package:ghiotta_app/widgets/qr.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) => QrView(
    validate: (token) => Uuid.isValidUUID(fromString: token),
    formBuilder: (context, token) => _NewDeviceForm(token: token),
  );
}

class _NewDeviceForm extends StatefulWidget {
  final String token;
  const _NewDeviceForm({required this.token});

  @override
  State<StatefulWidget> createState() => _NewDeviceFormState();
}

class _NewDeviceFormState extends State<_NewDeviceForm> {
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(label: Text("Name")),
                  ),
                ),
                SizedBox(width: 12),
                CheckboxMenuButton(
                  value: admin,
                  child: const Text("Admin"),
                  onChanged: (value) => setState(() {
                    admin = value ?? false;
                  }),
                ),
              ],
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
                    NewDevice(
                      name: _nameController.text,
                      admin: admin,
                      token: widget.token,
                      enabled: true,
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
