import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RootStackPage extends StatelessWidget {
  const RootStackPage({super.key});

  @override
  Widget build(BuildContext context) => const AutoRouter();
}
