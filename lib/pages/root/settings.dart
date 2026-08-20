import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghiotta_app/blocs/settings.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) => Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud),
                  title: Text(state.apiUrl?.toString() ?? "-"),
                  subtitle: Text("API Url"),
                  onTap: () async {
                    final value = await showDialog<Uri?>(
                      context: context,
                      builder: (_) => _SettingsUpdateDialog(
                        title: "API Url",
                        initialValue: state.apiUrl?.toString(),
                        validator: (value) {
                          context.read<Talker>().debug(
                            "Url validator input value: $value",
                          );
                          final result = value == null
                              ? null
                              : Uri.tryParse(value);
                          context.read<Talker>().debug(
                            "Url validator result: $result (tryParse result: ${Uri.tryParse(value ?? "")})",
                          );
                          return (result == null ||
                                  !["http", "https"].contains(result.scheme) ||
                                  result.host.isEmpty)
                              ? "Invalid URL"
                              : null;
                        },
                      ),
                    );
                    if (value != null && context.mounted) {
                      context.read<SettingsBloc>().add(
                        SettingsUpdate(apiUrl: value),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsUpdateDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String? Function(String?)? validator;

  const _SettingsUpdateDialog({
    required this.title,
    required this.initialValue,
    required this.validator,
  });

  @override
  State<StatefulWidget> createState() => _SettingsUpdateDialogState();
}

class _SettingsUpdateDialogState extends State<_SettingsUpdateDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  late bool isValid;

  @override
  void initState() {
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    super.initState();
    isValid = widget.validator?.call(widget.initialValue) == null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: _controller,
          validator: widget.validator,
          decoration: InputDecoration(labelText: widget.title),
          onChanged: (_) => setState(() {
            isValid = formKey.currentState?.validate() ?? false;
          }),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed: isValid
              ? () => Navigator.of(context).pop(Uri.tryParse(_controller.text))
              : null,
          child: Text("Ok"),
        ),
      ],
    );
  }
}
