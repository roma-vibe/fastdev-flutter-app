import 'dart:async';

import 'package:app/features/notes/domain/note.dart';
import 'package:app/features/notes/domain/notes_repository.dart';

class FakeNotesRepository implements NotesRepository {
  List<Note> notes = [];
  bool failLoad = false;
  bool failSave = false;
  Completer<void>? pendingSave;
  @override
  Future<List<Note>> load() async {
    if (failLoad) throw const FormatException('Stored data is invalid.');
    return List.unmodifiable(notes);
  }

  @override
  Future<void> save(List<Note> next) async {
    if (failSave) throw Exception('Disk unavailable.');
    if (pendingSave != null) await pendingSave!.future;
    notes = List.of(next);
  }
}
