import 'note.dart';

abstract interface class NotesRepository {
  Future<List<Note>> load();
  Future<void> save(List<Note> notes);
}
