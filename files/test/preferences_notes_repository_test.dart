import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:app/features/notes/data/preferences_notes_repository.dart';
import 'package:app/features/notes/domain/note.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );
  test('persists across repository instances and isolates projects', () async {
    final first = PreferencesNotesRepository(
      SharedPreferencesAsync(),
      namespace: 'one',
    );
    await first.save([
      Note(id: '1', text: 'idea', createdAt: DateTime.utc(2026)),
    ]);
    final reopened = PreferencesNotesRepository(
      SharedPreferencesAsync(),
      namespace: 'one',
    );
    expect((await reopened.load()).single.text, 'idea');
    expect(
      await PreferencesNotesRepository(
        SharedPreferencesAsync(),
        namespace: 'two',
      ).load(),
      isEmpty,
    );
  });
  test('corrupt data surfaces an error without overwriting it', () async {
    final preferences = SharedPreferencesAsync();
    final repository = PreferencesNotesRepository(
      preferences,
      namespace: 'one',
    );
    for (final invalid in ['{bad', '{}', '[42]', '[{"id":"1"}]']) {
      await preferences.setString(repository.key, invalid);
      await expectLater(repository.load(), throwsFormatException);
      expect(await preferences.getString(repository.key), invalid);
    }
  });
}
