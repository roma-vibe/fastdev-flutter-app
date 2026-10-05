import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/preferences.dart';
import '../domain/note.dart';
import '../domain/notes_repository.dart';

class PreferencesNotesRepository implements NotesRepository {
  PreferencesNotesRepository(this.preferences, {required String namespace})
    : key = '$namespace.notes.v1';
  final SharedPreferencesAsync preferences;
  final String key;
  @override
  Future<List<Note>> load() async {
    final raw = await preferences.getString(key);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Invalid notes storage.');
    return List.unmodifiable(
      decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid note data.');
        }
        return Note.fromJson(item);
      }),
    );
  }

  @override
  Future<void> save(List<Note> notes) => preferences.setString(
    key,
    jsonEncode(notes.map((note) => note.toJson()).toList()),
  );
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => PreferencesNotesRepository(
    ref.watch(preferencesProvider),
    namespace: ref.watch(appConfigProvider).slug,
  ),
);
