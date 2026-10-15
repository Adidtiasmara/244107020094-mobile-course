import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Infrastruktur database.
///
/// Sengaja diletakkan di `lib/infra/`, bukan `lib/core/`, karena modul
/// mewajibkan `lib/core` bebas dari import sqflite/Dio (grep sterilitas #2).
/// `core` menyimpan kontrak murni (failure, format), `infra` menyimpan
/// pembungkus framework yang dipakai lapisan `data`.
Future<Database> openNotesDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'offline_notes.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}

/// Database tunggal yang dipakai seluruh repository data.
final notesDbProvider = FutureProvider<Database>((ref) => openNotesDb());
