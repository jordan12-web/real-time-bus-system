import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/ai_message.dart';
import '../services/ai_service.dart';
import 'auth_controller.dart' show dioClientProvider;

final aiServiceProvider = Provider<AiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AiService(dioClient);
});

class AiAssistantState {
  final List<AiMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const AiAssistantState({
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
  });

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiAssistantController extends StateNotifier<AiAssistantState> {
  final AiService _aiService;

  AiAssistantController(this._aiService)
      : super(
          AiAssistantState(
            messages: [
              AiMessage(
                id: 'welcome',
                text: 'Hello! I am your Guzo Smart Passenger Assistant. Ask me about your bus location, assigned seat, schedule, or delays!',
                isUser: false,
                timestamp: DateTime.now(),
                confidence: 1.0,
                actionType: 'none',
              ),
            ],
          ),
        );

  Future<void> sendQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = AiMessage.user(trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    try {
      final responseData = await _aiService.queryAssistant(trimmed);
      final answer = responseData['answer']?.toString() ??
          'I could not retrieve an answer at this time.';
      final confidence = (responseData['confidence'] as num?)?.toDouble() ?? 0.9;
      final actionType = responseData['actionType']?.toString() ?? 'none';

      final aiMessage = AiMessage.fromAiResponse(
        text: answer,
        confidence: confidence,
        actionType: actionType,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      String errText = 'Failed to get a response. Please try again.';
      if (e is ApiException) {
        errText = e.message;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: errText,
        messages: [
          ...state.messages,
          AiMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            text: '⚠️ $errText',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      );
    }
  }

  void reset() {
    state = AiAssistantState(
      messages: [
        AiMessage(
          id: 'welcome',
          text: 'Hello! I am your Guzo Smart Passenger Assistant. Ask me about your bus location, assigned seat, schedule, or delays!',
          isUser: false,
          timestamp: DateTime.now(),
          confidence: 1.0,
          actionType: 'none',
        ),
      ],
    );
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantController, AiAssistantState>((ref) {
  final service = ref.watch(aiServiceProvider);
  return AiAssistantController(service);
});
