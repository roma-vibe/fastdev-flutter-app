import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../ui/surface.dart';
import '../../../ui/tokens.dart';
import '../../../ui/workspace_shell.dart';
import '../application/notes_controller.dart';
import '../domain/note.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});
  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool clear = false,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (clear && mounted) _text.clear();
    } on FormatException catch (error) {
      if (mounted) _showError(error.message);
    } on Exception {
      if (mounted) _showError('Could not save your changes. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesControllerProvider);
    final colors = UiColors(context);
    return WorkspaceShell(
      name: ref.watch(appConfigProvider).name,
      section: WorkspaceSection.notes,
      title: 'Your notes',
      subtitle: 'Capture a thought. Make space for what’s next.',
      onNotes: () {},
      onSettings: () => context.push('/settings'),
      children: [
        AppSurface(
          blur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: colors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'QUICK CAPTURE',
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _text,
                maxLength: Note.maxTextLength,
                minLines: 2,
                maxLines: 5,
                enabled: !_busy && notes.hasValue && !notes.hasError,
                decoration: const InputDecoration(
                  labelText: 'New note',
                  hintText: 'What is on your mind?',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _busy || !notes.hasValue || notes.hasError
                      ? null
                      : () => _run(
                          () => ref
                              .read(notesControllerProvider.notifier)
                              .add(_text.text),
                          clear: true,
                        ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(_busy ? 'Saving…' : 'Add note'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'All notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (notes.hasValue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.inset,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${notes.requireValue.length}',
                        style: TextStyle(color: colors.muted, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Newest first',
                style: TextStyle(color: colors.muted, fontSize: 12),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        notes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => AppSurface(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded),
                const SizedBox(height: 12),
                const Text('Could not load notes. Stored data has been kept.'),
                TextButton(
                  onPressed: () => ref.invalidate(notesControllerProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (items) => items.isEmpty
              ? AppSurface(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.inset,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notes_rounded,
                          size: 28,
                          color: colors.accent,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Good ideas start here.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No notes yet. Add your first idea above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.muted),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 620 ? 2 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final note in items)
                          SizedBox(
                            width: width,
                            child: _NoteCard(
                              note: note,
                              onDelete: _busy
                                  ? null
                                  : () => _run(
                                      () => ref
                                          .read(
                                            notesControllerProvider.notifier,
                                          )
                                          .remove(note.id),
                                    ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onDelete});
  final Note note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => AppSurface(
    key: ValueKey(note.id),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.notes_rounded, size: 20, color: UiColors(context).accent),
        const SizedBox(height: 16),
        SelectableText(note.text, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                note.createdAt.toLocal().toIso8601String().substring(0, 10),
                style: TextStyle(color: UiColors(context).muted, fontSize: 12),
              ),
            ),
            IconButton(
              tooltip: 'Delete note',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
            ),
          ],
        ),
      ],
    ),
  );
}
