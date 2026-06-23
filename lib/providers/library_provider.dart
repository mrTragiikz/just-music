import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/song.dart';
import '../data/services/music_library_service.dart';

enum SongSortBy { name, artist, album, dateAdded, duration, fileSize }

class LibraryProvider extends ChangeNotifier {
  final MusicLibraryService _service = MusicLibraryService();

  List<Song> _songs = [];
  List<ArtistModel> _artists = [];
  List<AlbumModel> _albums = [];
  bool isLoading = false;
  bool permissionDenied = false;

  Set<int> _favoriteIds = {};
  final List<int> _recentlyPlayedIds = [];
  final Map<int, int> _playCounts = {};

  SongSortBy sortBy = SongSortBy.name;
  bool sortAscending = true;

  static const _keyFavorites = 'favorite_song_ids';
  static const _keyRecent = 'recently_played_ids';
  static const _keyPlayCounts = 'play_counts';

  late SharedPreferences _prefs;

  List<Song> get songs => _songs;
  List<ArtistModel> get artists => _artists;
  List<AlbumModel> get albums => _albums;
  MusicLibraryService get service => _service;

  List<Song> get favoriteSongs =>
      _songs.where((s) => _favoriteIds.contains(s.id)).toList();

  List<Song> get recentlyPlayed => _recentlyPlayedIds
      .map((id) => _songs.where((s) => s.id == id).firstOrNull)
      .whereType<Song>()
      .toList();

  List<Song> get recentlyAdded {
    final sorted = [..._songs]..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sorted.take(10).toList();
  }

  List<Song> get mostPlayed {
    final sorted = [..._songs]
      ..sort((a, b) => (_playCounts[b.id] ?? 0).compareTo(_playCounts[a.id] ?? 0));
    return sorted.where((s) => (_playCounts[s.id] ?? 0) > 0).toList();
  }

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _favoriteIds = (_prefs.getStringList(_keyFavorites) ?? [])
        .map(int.parse)
        .toSet();
    _recentlyPlayedIds.addAll(
      (_prefs.getStringList(_keyRecent) ?? []).map(int.parse),
    );
    final rawCounts = _prefs.getStringList(_keyPlayCounts) ?? [];
    for (final entry in rawCounts) {
      final parts = entry.split(':');
      _playCounts[int.parse(parts[0])] = int.parse(parts[1]);
    }
    await scanLibrary();
  }

  Future<void> scanLibrary({List<String> excludedFolders = const []}) async {
    isLoading = true;
    notifyListeners();

    final hasPermission = await _service.requestPermission();
    if (!hasPermission) {
      permissionDenied = true;
      isLoading = false;
      notifyListeners();
      return;
    }
    permissionDenied = false;

    _songs = await _service.fetchAllSongs(excludedFolders: excludedFolders);
    _artists = await _service.fetchAllArtists();
    _albums = await _service.fetchAllAlbums();
    applySort();

    isLoading = false;
    notifyListeners();
  }

  void applySort([SongSortBy? newSortBy, bool? ascending]) {
    sortBy = newSortBy ?? sortBy;
    sortAscending = ascending ?? sortAscending;

    int compare(Song a, Song b) {
      switch (sortBy) {
        case SongSortBy.name:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SongSortBy.artist:
          return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        case SongSortBy.album:
          return a.album.toLowerCase().compareTo(b.album.toLowerCase());
        case SongSortBy.dateAdded:
          return a.dateAdded.compareTo(b.dateAdded);
        case SongSortBy.duration:
          return a.duration.compareTo(b.duration);
        case SongSortBy.fileSize:
          return a.fileSize.compareTo(b.fileSize);
      }
    }

    _songs.sort(sortAscending ? compare : (a, b) => compare(b, a));
    notifyListeners();
  }

  Future<void> toggleFavorite(int songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    await _prefs.setStringList(
      _keyFavorites,
      _favoriteIds.map((e) => e.toString()).toList(),
    );
    notifyListeners();
  }

  Future<void> recordPlay(int songId) async {
    _recentlyPlayedIds.remove(songId);
    _recentlyPlayedIds.insert(0, songId);
    if (_recentlyPlayedIds.length > 50) {
      _recentlyPlayedIds.removeRange(50, _recentlyPlayedIds.length);
    }
    _playCounts[songId] = (_playCounts[songId] ?? 0) + 1;

    await _prefs.setStringList(
      _keyRecent,
      _recentlyPlayedIds.map((e) => e.toString()).toList(),
    );
    await _prefs.setStringList(
      _keyPlayCounts,
      _playCounts.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
    notifyListeners();
  }

  List<Song> searchSongs(String query) {
    final lower = query.toLowerCase();
    return _songs
        .where((s) =>
            s.title.toLowerCase().contains(lower) ||
            s.artist.toLowerCase().contains(lower) ||
            s.album.toLowerCase().contains(lower))
        .toList();
  }
}
