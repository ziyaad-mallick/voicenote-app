class Reminder {
  final String id;
  String text;
  DateTime? dateTime;
  bool fired;

  Reminder({
    required this.id,
    required this.text,
    this.dateTime,
    this.fired = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'dateTime': dateTime?.toIso8601String(),
        'fired': fired,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        text: json['text'] as String? ?? '',
        dateTime: json['dateTime'] != null
            ? DateTime.tryParse(json['dateTime'] as String)
            : null,
        fired: json['fired'] as bool? ?? false,
      );
}
