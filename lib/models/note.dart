import 'reminder.dart';

/// A single voice note after transcription + formatting.
class Note {
  final String id;
  String title;

  /// Formatted note content as Markdown.
  String body;

  /// One- or two-sentence TL;DR.
  String summary;

  /// One of the user's configured categories.
  String category;

  List<String> tags;

  /// The original raw transcript from speech-to-text.
  String rawTranscript;

  final DateTime createdAt;

  List<Reminder> reminders;

  Note({
    required this.id,
    required this.title,
    required this.body,
    this.summary = '',
    this.category = 'Personal',
    List<String>? tags,
    this.rawTranscript = '',
    required this.createdAt,
    List<Reminder>? reminders,
  })  : tags = tags ?? [],
        reminders = reminders ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'summary': summary,
        'category': category,
        'tags': tags,
        'rawTranscript': rawTranscript,
        'createdAt': createdAt.toIso8601String(),
        'reminders': reminders.map((r) => r.toJson()).toList(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Untitled',
        body: json['body'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        category: json['category'] as String? ?? 'Personal',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        rawTranscript: json['rawTranscript'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        reminders: (json['reminders'] as List?)
                ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
