import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/driver_trip_controller.dart';
import '../core/permissions.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasCameraPermission = false;
  bool _isProcessing = false;
  bool _awaitingNextScan = false;

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
    if (_isProcessing || _awaitingNextScan) return;
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);
    await ref.read(driverTripControllerProvider.notifier).validateTicket(rawValue);
    await _controller.stop();
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _awaitingNextScan = true;
      });
    }
  }

  Future<void> _handleScanNext() async {
    await _controller.start();
    if (mounted) setState(() => _awaitingNextScan = false);
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(driverTripControllerProvider);
    final result = tripState.lastValidation;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    return AppScaffold(
      title: 'Ticket Validation',
      child: Column(
        children: [
          // Top Viewfinder Box
          Expanded(
            flex: 3,
            child: !_hasCameraPermission
                ? PolishedCard(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: isDark ? Colors.white54 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),
                          const Text(
                            'Camera Permission Required',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
                            child: Text(
                              'Please grant camera access to scan passenger QR ticket codes for boarding.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceLg),
                          PolishedButton(
                            buttonKey: const Key('scan_qr_button'),
                            label: 'Grant Camera Permission',
                            icon: Icons.security_rounded,
                            expand: false,
                            onPressed: _requestPermission,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal - 2),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          MobileScanner(
                            controller: _controller,
                            onDetect: _handleDetection,
                          ),
                          // Viewfinder Reticle Overlay
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Bottom Validation Result Card
          Expanded(
            flex: 2,
            child: tripState.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: DesignTokens.spaceSm),
                        Text('Validating passenger ticket...'),
                      ],
                    ),
                  )
                : result == null
                    ? PolishedCard(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 40,
                                color: primary,
                              ),
                              const SizedBox(height: DesignTokens.spaceSm),
                              const Text(
                                'Ready to Scan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Point camera at passenger\'s ticket QR code to verify booking and admit for boarding.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(DesignTokens.spaceMd),
                              decoration: BoxDecoration(
                                color: result.valid
                                    ? DesignTokens.statusConfirmed.withValues(alpha: 0.12)
                                    : DesignTokens.statusCancelled.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                                border: Border.all(
                                  color: result.valid
                                      ? DesignTokens.statusConfirmed.withValues(alpha: 0.5)
                                      : DesignTokens.statusCancelled.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        result.valid
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: result.valid
                                            ? DesignTokens.statusConfirmed
                                            : DesignTokens.statusCancelled,
                                        size: 28,
                                      ),
                                      const SizedBox(width: DesignTokens.spaceSm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result.valid
                                                  ? 'Valid Ticket — Passenger Admitted'
                                                  : 'Invalid Ticket',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: result.valid
                                                    ? DesignTokens.statusConfirmed
                                                    : DesignTokens.statusCancelled,
                                              ),
                                            ),
                                            if (result.bookingId != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Booking ID: ${result.bookingId}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (result.reason != null) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Divider(height: 1),
                                    ),
                                    Text(
                                      result.reason!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (_awaitingNextScan) ...[
                              const SizedBox(height: DesignTokens.spaceMd),
                              PolishedButton(
                                buttonKey: const Key('scan_next_ticket_button'),
                                label: 'Scan Next Ticket',
                                icon: Icons.qr_code_scanner_rounded,
                                variant: PolishedButtonVariant.primary,
                                onPressed: _handleScanNext,
                              ),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}