import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/notes/application/notes_controller.dart';
import 'package:app/features/notes/data/preferences_notes_repository.dart';

import 'support/fakes.dart';

void main() {
  late FakeNotesRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = FakeNotesRepository();
    container = ProviderContainer.test(
      overrides: [notesRepositoryProvider.overrideWithValue(repository)],
    );
  });
  test('adds newest first, trims text and removes by ID', () async {
    await container.read(notesControllerProvider.future);
    final controller = container.read(notesControllerProvider.notifier);
    await controller.add(' first ');
    await controller.add('second');
    expect(repository.notes.map((note) => note.text), ['second', 'first']);
    expect(repository.notes.map((note) => note.id).toSet(), hasLength(2));
    await controller.remove(repository.notes.first.id);
    expect(
      container.read(notesControllerProvider).requireValue.single.text,
      'first',
    );
  });
  test('failed writes preserve state and permit a retry', () async {
    await container.read(notesControllerProvider.future);
    final controller = container.read(notesControllerProvider.notifier);
    await controller.add('existing');
    repository.failSave = true;
    await expectLater(controller.add('new'), throwsException);
    expect(
      container.read(notesControllerProvider).requireValue.single.text,
      'existing',
    );
    repository.failSave = false;
    await controller.add('retry');
    expect(repository.notes.map((note) => note.text), ['retry', 'existing']);
  });
  test('rejects concurrent writes so updates cannot be lost', () async {
    await container.read(notesControllerProvider.future);
    repository.pendingSave = Completer<void>();
    final controller = container.read(notesControllerProvider.notifier);
    final first = controller.add('first');
    await expectLater(controller.add('second'), throwsStateError);
    repository.pendingSave!.complete();
    await first;
    expect(repository.notes.single.text, 'first');
  });
  test('load errors are visible until explicitly retried', () async {
    repository.failLoad = true;
    await expectLater(
      container.read(notesControllerProvider.future),
      throwsA(isA<FormatException>()),
    );
    expect(container.read(notesControllerProvider).hasError, isTrue);
    repository.failLoad = false;
    container.invalidate(notesControllerProvider);
    expect(await container.read(notesControllerProvider.future), isEmpty);
  });
}
