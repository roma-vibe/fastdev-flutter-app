import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/preferences_notes_repository.dart';
import '../domain/note.dart';

class NotesController extends AsyncNotifier<List<Note>> {
  bool _saving = false;
  var _sequence = 0;
  @override
  Future<List<Note>> build() => ref.watch(notesRepositoryProvider).load();
  Future<void> add(String text) async {
    final value = Note.validateText(text);
    final now = DateTime.now().toUtc();
    await _save(
      (notes) => [
        Note(
          id: '${now.microsecondsSinceEpoch}-${_sequence++}',
          text: value,
          createdAt: now,
        ),
        ...notes,
      ],
    );
  }

  Future<void> remove(String id) =>
      _save((notes) => notes.where((note) => note.id != id).toList());
  Future<void> _save(List<Note> Function(List<Note>) update) async {
    if (_saving) throw StateError('A save is already in progress.');
    final current = state.value;
    if (current == null || state.hasError) {
      throw StateError('Load notes before making changes.');
    }
    _saving = true;
    try {
      final next = List<Note>.unmodifiable(update(current));
      await ref.read(notesRepositoryProvider).save(next);
      if (ref.mounted) state = AsyncData(next);
    } finally {
      _saving = false;
    }
  }
}

final notesControllerProvider =
    AsyncNotifierProvider<NotesController, List<Note>>(
      NotesController.new,
      retry: (retryCount, error) => null,
    );
