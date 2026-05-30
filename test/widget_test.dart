// Basic smoke test for VoiceNote.
import 'package:flutter_test/flutter_test.dart';

import 'package:voicenote/models/note.dart';

void main() {
  test('Note serializes and deserializes round-trip', () {
    final note = Note(
      id: 'abc',
      title: 'Test',
      body: 'Hello world',
      summary: 'A test note',
      category: 'Ideas',
      tags: ['x', 'y'],
      createdAt: DateTime(2026, 1, 1, 12),
    );

    final restored = Note.fromJson(note.toJson());

    expect(restored.id, 'abc');
    expect(restored.title, 'Test');
    expect(restored.category, 'Ideas');
    expect(restored.tags, ['x', 'y']);
  });
}
