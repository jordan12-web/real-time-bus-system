import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/ticket_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

/// Ticket Screen displaying generated ticket and QR code.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  String? _bookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bookingId ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _handleGenerateTicket() async {
    if (_bookingId == null) return;
    await ref
        .read(ticketControllerProvider.notifier)
        .generateTicket(_bookingId!);
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketControllerProvider);

    return AppScaffold(
      title: 'Digital Ticket',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Booking ID: ${_bookingId ?? 'N/A'}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (ticketState.result != null) ...[
              Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ticketState.result!.qrCodeData != null &&
                            ticketState.result!.qrCodeData!.isNotEmpty)
                          QrImageView(
                            key: const Key('ticket_qr'),
                            data: ticketState.result!.qrCodeData!,
                            version: QrVersions.auto,
                            size: 200.0,
                          )
                        else
                          Container(
                            key: const Key('ticket_qr'),
                            width: 200,
                            height: 200,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: Text(
                              ticketState.result!.ticket.id,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text('Ticket Status: ${ticketState.result!.ticket.status}'),
                        if (ticketState.result!.ticket.issuedAt != null)
                          Text('Issued: ${ticketState.result!.ticket.issuedAt}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (ticketState.errorMessage != null) ...[
              Text(
                ticketState.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            PrimaryButton(
              key: const Key('generate_ticket_button'),
              text: ticketState.result == null ? 'Generate Ticket' : 'Re-generate Ticket',
              isLoading: ticketState.isLoading,
              onPressed: _bookingId != null ? _handleGenerateTicket : null,
            ),
          ],
        ),
      ),
    );
  }
}
