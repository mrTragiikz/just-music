import 'package:flutter/foundation.dart';
import '../data/models/playlist.dart';
import '../data/repositories/playlist_repository.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _repo = PlaylistRepository();
  List<Playlist> _playlists = [];
  bool isLoading = true;

  List<Playlist> get playlists => _playlists;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _playlists = await _repo.getAll();
    isLoading = false;
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    await _repo.create(name);
    await load();
  }

  Future<void> renamePlaylist(int id, String newName) async {
    await _repo.rename(id, newName);
    await load();
  }

  Future<void> deletePlaylist(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _repo.addSong(playlistId, songId);
    await load();
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _repo.removeSong(playlistId, songId);
    await load();
  }
}
