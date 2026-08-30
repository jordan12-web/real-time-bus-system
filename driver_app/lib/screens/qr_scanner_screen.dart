import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/driver_trip_controller.dart';
import '../core/permissions.dart';
import '../widgets/app_scaffold.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasCameraPermission = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final granted = await AppPermissions.requestCamera();
    if (mounted) setState(() => _hasCameraPermission = granted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);
    await ref.read(driverTripControllerProvider.notifier).validateTicket(rawValue);
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(driverTripControllerProvider);
    final result = tripState.lastValidation;

    return AppScaffold(
      title: 'Scan Ticket',
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: !_hasCameraPermission
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Camera permission is required to scan tickets.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          key: const Key('scan_qr_button'),
                          onPressed: _requestPermission,
                          child: const Text('Grant Camera Permission'),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MobileScanner(
                      controller: _controller,
                      onDetect: _handleDetection,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: tripState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : result == null
                    ? const Center(child: Text('Point the camera at a passenger\'s QR code.'))
                    : Card(
                        color: result.valid ? Colors.green.shade50 : Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    result.valid ? Icons.check_circle : Icons.cancel,
                                    color: result.valid ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    result.valid ? 'Valid — passenger admitted' : 'Invalid ticket',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (result.reason != null) ...[
                                const SizedBox(height: 6),
                                Text(result.reason!),
                              ],
                              if (result.bookingId != null) ...[
                                const SizedBox(height: 6),
                                Text('Booking: ${result.bookingId}'),
                              ],
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}