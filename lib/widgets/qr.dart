import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:talker_flutter/talker_flutter.dart';

class QrView extends StatefulWidget {
  final bool Function(String token) validate;
  final Widget Function(BuildContext context, String token) formBuilder;
  const QrView({super.key, required this.validate, required this.formBuilder});

  @override
  State<StatefulWidget> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  late final MobileScannerController _controller;
  String? token;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: token == null ? Colors.black54 : null,
        iconTheme: token == null ? IconThemeData(color: Colors.white) : null,
        title: Text(
          "Scan authorization QR",
          style: token == null ? TextStyle(color: Colors.white) : null,
        ),
        actions: [
          if (token == null)
            IconButton(
              icon: ListenableBuilder(
                listenable: _controller,
                builder: (_, _) => Icon(switch (_controller.value.torchState) {
                  TorchState.on => Icons.flash_on,
                  TorchState.off || TorchState.unavailable => Icons.flash_off,
                  TorchState.auto => Icons.flash_auto, // probably never
                }),
              ),
              onPressed: _controller.toggleTorch,
            ),
        ],
      ),
      body: switch (token) {
        String token => widget.formBuilder(context, token),
        null => LayoutBuilder(
          builder: (context, constraints) {
            final baseSize = constraints.maxHeight;
            final scanWindow = Rect.fromCenter(
              center: constraints.biggest.center(Offset.zero),
              width: baseSize * .3,
              height: baseSize * .3,
            );
            final talker = context.read<Talker>();

            return MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (!mounted) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;

                final barcode = barcodes.first;
                final rawValue = barcode.rawValue;
                if (rawValue == null) return;

                talker.debug("QR Scan: $rawValue");

                if (widget.validate(rawValue)) {
                  setState(() {
                    token = rawValue;
                  });
                }
              },
              onDetectError: context.read<Talker>().handle,
              scanWindow: scanWindow,
              overlayBuilder: (context, overlayConstraints) {
                return Stack(
                  children: [
                    ClipPath(
                      clipper: _ScannerOverlayClipper(
                        holeRect: scanWindow,
                        borderRadius: 16,
                      ),
                      child: Container(
                        width: overlayConstraints.maxWidth,
                        height: overlayConstraints.maxHeight,
                        color: Colors.black87,
                      ),
                    ),

                    Positioned.fromRect(
                      rect: scanWindow,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: .all(color: Colors.white, width: 2),
                            borderRadius: .circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      },
    );
  }
}

class _ScannerOverlayClipper extends CustomClipper<Path> {
  final Rect holeRect;
  final double borderRadius;

  const _ScannerOverlayClipper({
    required this.holeRect,
    this.borderRadius = 16,
  });

  @override
  Path getClip(Size size) {
    return Path()
      ..fillType = .evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(holeRect, .circular(borderRadius)));
  }

  @override
  bool shouldReclip(covariant _ScannerOverlayClipper oldClipper) => false;
}
