import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/playlist.dart';

class PlaylistRepository {
  static const _table = 'playlists';
  Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'offline_music_player.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            songIds TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Playlist>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map(Playlist.fromMap).toList();
  }

  Future<Playlist> create(String name) async {
    final db = await _database;
    final playlist = Playlist(name: name, songIds: [], createdAt: DateTime.now());
    final id = await db.insert(_table, playlist.toMap());
    return playlist.copyWith(id: id);
  }

  Future<void> rename(int id, String newName) async {
    final db = await _database;
    await db.update(_table, {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addSong(int playlistId, int songId) async {
    final playlists = await getAll();
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    if (playlist.songIds.contains(songId)) return;
    final updated = [...playlist.songIds, songId];
    await _updateSongIds(playlistId, updated);
  }

  Future<void> removeSong(int playlistId, int songId) async {
    final playlists = await getAll();
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    final updated = playlist.songIds.where((id) => id != songId).toList();
    await _updateSongIds(playlistId, updated);
  }

  Future<void> _updateSongIds(int playlistId, List<int> songIds) async {
    final db = await _database;
    await db.update(
      _table,
      {'songIds': songIds.join(',')},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }
}
