import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import 'llm_client.dart';

class FormatterService {
  static Future<Note> format(
    String transcript, {
    required List<String> categories,
    required String apiKey,
  }) async {
    final llmClient = LlmClient(apiKey);

    if (llmClient.hasKey) {
      final result = await llmClient.formatTranscript(transcript, categories);
      if (result != null) {
        return _buildNoteFromLlm(result, transcript, categories);
      }
    }

    return _ruleBased(transcript, categories);
  }

  static Note _buildNoteFromLlm(
    Map<String, dynamic> result,
    String transcript,
    List<String> categories,
  ) {
    final title = (result['title'] as String?) ?? '';
    var category = (result['category'] as String?) ?? '';

    if (!categories.contains(category)) {
      category = categories.isNotEmpty ? categories.first : 'General';
    }

    final summary = (result['summary'] as String?) ?? '';
    final body = (result['body'] as String?) ?? '';
    final tagsList = result['tags'] as List<dynamic>?;
    final tags =
        tagsList?.map((t) => t.toString()).toList() ?? <String>[];
    final remindersList = result['reminders'] as List<dynamic>?;

    final reminders = <Reminder>[];
    if (remindersList != null) {
      for (final reminder in remindersList) {
        if (reminder is Map<String, dynamic>) {
          final text = (reminder['text'] as String?) ?? '';
          final datetimeStr = (reminder['datetime'] as String?) ?? '';
          DateTime? dateTime = DateTime.tryParse(datetimeStr);
          if (text.isNotEmpty) {
            reminders.add(
              Reminder(
                id: const Uuid().v4(),
                text: text,
                dateTime: dateTime,
                fired: false,
              ),
            );
          }
        }
      }
    }

    return Note(
      id: const Uuid().v4(),
      title: title,
      body: body,
      summary: summary,
      category: category,
      tags: tags.isNotEmpty ? tags : null,
      rawTranscript: transcript,
      createdAt: DateTime.now(),
      reminders: reminders.isNotEmpty ? reminders : null,
    );
  }

  static Note _ruleBased(String transcript, List<String> categories) {
    final title = _extractTitle(transcript);
    final category = _extractCategory(transcript, categories);
    final summary = _extractSummary(transcript);
    final body = _formatBody(transcript);

    return Note(
      id: const Uuid().v4(),
      title: title,
      body: body,
      summary: summary,
      category: category,
      tags: null,
      rawTranscript: transcript,
      createdAt: DateTime.now(),
      reminders: null,
    );
  }

  static String _extractTitle(String transcript) {
    final sentences = transcript.split('. ');
    String title = sentences.first.trim();

    if (title.length > 60) {
      final words = title.split(' ');
      title = words.take(8).join(' ').trim();

      if (title.length > 60) {
        title = title.substring(0, 60).trim();
      }
    }

    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1).toLowerCase();
    }

    return title;
  }

  static String _extractCategory(String transcript, List<String> categories) {
    final lowerTranscript = transcript.toLowerCase();

    for (final category in categories) {
      if (lowerTranscript.contains(category.toLowerCase())) {
        return category;
      }
    }

    return categories.isNotEmpty ? categories.first : 'General';
  }

  static String _extractSummary(String transcript) {
    final sentences = transcript.split('. ');
    return sentences.first.trim();
  }

  static String _formatBody(String transcript) {
    final sentences = transcript.split('. ');
    final capitalizedSentences = sentences
        .map((s) {
          final trimmed = s.trim();
          if (trimmed.isEmpty) return '';
          return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
        })
        .where((s) => s.isNotEmpty)
        .toList();

    return capitalizedSentences.join('. ');
  }
}
