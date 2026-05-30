import 'package:http/http.dart' as http;
import 'dart:convert';

class LlmClient {
  final String apiKey;

  LlmClient(this.apiKey);

  bool get hasKey => apiKey.trim().isNotEmpty;

  Future<Map<String, dynamic>?> formatTranscript(
    String transcript,
    List<String> categories,
  ) async {
    if (!hasKey) {
      return null;
    }

    final systemPrompt = _buildSystemPrompt(categories);

    final requestBody = {
      'model': 'llama-3.3-70b-versatile',
      'temperature': 0.2,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': 'Transcript:\n\n$transcript',
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            responseData['choices'][0]['message']['content'] as String;
        final result = jsonDecode(content) as Map<String, dynamic>;
        return result;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _buildSystemPrompt(List<String> categories) {
    final categoriesStr = categories.join(', ');
    return '''You are a note formatter. Analyze the provided transcript and return ONLY a valid JSON object with the following structure:
{
  "title": "string (max 60 characters)",
  "category": "string (MUST be one of: $categoriesStr)",
  "summary": "string (1-2 sentences)",
  "body": "string (clean Markdown with headings/bullets where useful, grammar fixed)",
  "tags": ["string", ...] (3-6 lowercase strings),
  "reminders": [{"text": "string", "datetime": "ISO-8601 or descriptive like 'tomorrow 9am'"}, ...] (empty array if no dates/tasks mentioned)
}

Ensure all values are strings or arrays as specified. Return only the JSON object, no additional text.''';
  }
}
