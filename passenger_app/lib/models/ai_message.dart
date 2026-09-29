class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final double? confidence;
  final String? actionType;

  const AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidence,
    this.actionType,
  });

  factory AiMessage.fromAiResponse({
    required String text,
    double? confidence,
    String? actionType,
  }) {
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      confidence: confidence,
      actionType: actionType,
    );
  }

  factory AiMessage.user(String text) {
    return AiMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }
}
