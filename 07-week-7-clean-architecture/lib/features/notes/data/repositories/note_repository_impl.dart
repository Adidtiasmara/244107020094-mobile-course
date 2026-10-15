import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

/// Implementasi kontrak `NoteRepository` memakai SQLite.
///
/// `openDb` disuntikkan agar test dapat memakai database in-memory/fake tanpa
/// menyentuh SQLite sungguhan. Seluruh exception platform ditangkap di sini dan
/// diubah menjadi `LocalFailure`, sehingga presentation tidak pernah melihat
/// exception mentah.
class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required this.openDb});

  final Future<Database> Function() openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes =
          rows.map((row) => NoteModel.fromMap(row).toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> getNote(int id) async {
    try {
      final db = await openDb();
      final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) return (note: null, failure: null);
      return (note: NoteModel.fromMap(rows.first).toEntity(), failure: null);
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal membaca catatan: $e'));
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final db = await openDb();
      final now = DateTime.now();
      final model = NoteModel(
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      );
      final id = await db.insert('notes', model.toMap());
      return (
        note: Note(
          id: id,
          title: title,
          body: body,
          updatedAt: now,
          dirty: true,
        ),
        failure: null,
      );
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan catatan: $e'));
    }
  }

  @override
  Future<({Failure? failure})> deleteNote(int id) async {
    try {
      final db = await openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal menghapus catatan: $e'));
    }
  }

  @override
  Future<({int count, Failure? failure})> countDirty() async {
    try {
      final db = await openDb();
      final rows =
          await db.rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
      return (count: (rows.first['c'] as num?)?.toInt() ?? 0, failure: null);
    } catch (e) {
      return (count: 0, failure: LocalFailure('Gagal menghitung catatan: $e'));
    }
  }

  @override
  Future<({Failure? failure})> markAllSynced() async {
    try {
      final db = await openDb();
      await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      return (failure: null);
    } catch (e) {
      return (failure: LocalFailure('Gagal menandai sinkron: $e'));
    }
  }
}
