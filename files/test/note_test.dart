import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/notes/domain/note.dart';

void main() {
  test('round-trips UTC timestamps and Unicode text', () {
    final note = Note(
      id: 'id',
      text: 'Идея "x"',
      createdAt: DateTime.utc(2026, 10, 2),
    );
    final restored = Note.fromJson(note.toJson());
    expect(restored.id, note.id);
    expect(restored.text, note.text);
    expect(restored.createdAt, note.createdAt);
  });
  test('validates empty, long and malformed notes', () {
    expect(Note.validateText('  hello  '), 'hello');
    expect(() => Note.validateText(' '), throwsFormatException);
    expect(() => Note.validateText('a' * 501), throwsFormatException);
    expect(() => Note.fromJson({'id': 42}), throwsFormatException);
    expect(
      () => Note.fromJson({'id': 'id', 'text': 'a', 'createdAt': 'invalid'}),
      throwsFormatException,
    );
  });
}
