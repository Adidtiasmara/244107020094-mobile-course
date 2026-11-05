import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infra/network.dart';
import '../../../../routes.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_tile.dart';

/// Filter catatan berdasarkan kata kunci pada judul.
List<Note> filterNotes(List<Note> notes, String query) {
  if (query.isEmpty) return notes;
  final keyword = query.toLowerCase();
  return notes
      .where((note) => note.title.toLowerCase().contains(keyword))
      .toList();
}

/// Halaman daftar catatan. Hanya membaca state dari provider; tidak menyentuh
/// SQLite, Dio, JSON, atau formatting tanggal secara langsung.
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  bool _syncing = false;
  String _query = '';

  Future<void> _openAddDialog() async {
    final draft = await showDialog<({String title, String body})>(
      context: context,
      builder: (_) => const _AddNoteDialog(),
    );
    if (draft == null) return;
    final result = await ref
        .read(notesProvider.notifier)
        .add(title: draft.title, body: draft.body);
    if (!mounted) return;
    final failure = result.failure;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan catatan: ${failure.message}')),
      );
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    final result = await ref.read(syncNotesProvider).call();
    ref.invalidate(notesProvider);
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.failure != null
              ? 'Gagal sinkron: ${result.failure!.message}'
              : result.synced == 0
              ? 'Tidak ada catatan yang perlu disinkronkan.'
              : '${result.synced} catatan berhasil disinkronkan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final offline = ref.watch(forceOfflineProvider);
    final dirtyCount = ref.watch(dirtyCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            tooltip: 'Data API (cache-first)',
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () => context.go(AppRoutes.posts),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.deepOrange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.airplanemode_active,
                    size: 18,
                    color: Colors.deepOrange.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode offline aktif - catatan tetap bisa dibaca & ditulis.',
                      style: TextStyle(color: Colors.deepOrange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Icon(
                  dirtyCount == 0
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_upload_outlined,
                  size: 18,
                  color: dirtyCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dirtyCount == 0
                        ? 'Semua catatan sudah tersinkron'
                        : '$dirtyCount catatan belum tersinkron',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: (_syncing || offline) ? null : _sync,
                  icon: _syncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync, size: 18),
                  label: const Text('Sync'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Cari judul catatan...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat catatan: $error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            ref.read(notesProvider.notifier).refresh(),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan. Tekan + untuk menambah.'),
                  );
                }
                final results = filterNotes(items, _query);
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'Catatan dengan judul "$_query" tidak ditemukan.',
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final note = results[index];
                    return NoteTile(
                      note: note,
                      onTap: () => context.go(AppRoutes.noteDetail(note.id!)),
                      onDelete: () async {
                        if (note.id != null) {
                          await ref
                              .read(notesProvider.notifier)
                              .remove(note.id!);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }
}

/// Dialog tambah catatan.
///
/// Controller hidup bersama widget dialog ini dan dibuang di `dispose()`,
/// jadi tidak ada controller yang dipakai setelah dibuang saat animasi tutup.
/// Hasil dikembalikan sebagai record `({String title, String body})`.
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _titleError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = true);
      return;
    }
    Navigator.of(
      context,
    ).pop((title: title, body: _bodyController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            onChanged: (_) {
              if (_titleError && _titleController.text.trim().isNotEmpty) {
                setState(() => _titleError = false);
              }
            },
            decoration: InputDecoration(
              labelText: 'Judul',
              border: const OutlineInputBorder(),
              errorText: _titleError ? 'Judul tidak boleh kosong' : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Isi (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
