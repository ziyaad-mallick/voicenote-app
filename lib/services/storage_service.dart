import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('notes');
  }

  List<Note> getAll() {
    final notes = <Note>[];

    for (final value in _box.values) {
      try {
        final decoded = jsonDecode(value as String) as Map<String, dynamic>;
        notes.add(Note.fromJson(decoded));
      } catch (e) {
        debugPrint('Error decoding note: $e');
      }
    }

    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  Note? getById(String id) {
    final value = _box.get(id);
    if (value == null) return null;

    try {
      final decoded = jsonDecode(value as String) as Map<String, dynamic>;
      return Note.fromJson(decoded);
    } catch (e) {
      debugPrint('Error decoding note $id: $e');
      return null;
    }
  }

  Future<void> save(Note note) async {
    await _box.put(note.id, jsonEncode(note.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
