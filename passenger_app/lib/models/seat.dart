/// Minimal seat model for seat selection UI and reservation flow.
class Seat {
  final String id;
  final String label;
  final bool isAvailable;

  const Seat({
    required this.id,
    required this.label,
    required this.isAvailable,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? json['seat_number']?.toString() ?? '',
      isAvailable: json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'is_available': isAvailable,
  };
}
