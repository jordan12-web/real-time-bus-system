import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../repositories/ticket_repository.dart';
import 'auth_controller.dart' show ticketRepositoryProvider;

class TicketState {
  final bool isLoading;
  final TicketGenerationResult? result;
  final String? errorMessage;

  const TicketState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  TicketState copyWith({
    bool? isLoading,
    TicketGenerationResult? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TicketState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TicketController extends StateNotifier<TicketState> {
  final TicketRepository _repository;

  TicketController(this._repository) : super(const TicketState());

  /// Idempotency lives in TicketRepository.generateTicket — calling this
  /// again for an already-issued booking returns the cached ticket instead
  /// of generating a second one.
  Future<bool> generateTicket(String bookingId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.generateTicket(bookingId);
      state = state.copyWith(isLoading: false, result: result);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return false;
    }
  }
}

final ticketControllerProvider =
    StateNotifierProvider<TicketController, TicketState>((ref) {
  return TicketController(ref.watch(ticketRepositoryProvider));
});