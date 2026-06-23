import 'dart:typed_data';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

class MusicLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.audio.request();
    if (status.isGranted) return true;
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<bool> hasPermission() async {
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;
    final storageStatus = await Permission.storage.status;
    return storageStatus.isGranted;
  }

  Future<List<Song>> fetchAllSongs({List<String> excludedFolders = const []}) async {
    final List<SongModel> models = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return models
        .where((m) => m.isMusic ?? true)
        .where((m) => excludedFolders.isEmpty ||
            !excludedFolders.any((folder) => (m.data).startsWith(folder)))
        .map(_mapSong)
        .toList();
  }

  Future<List<ArtistModel>> fetchAllArtists() {
    return _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }

  Future<List<AlbumModel>> fetchAllAlbums() {
    return _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }

  Future<List<Song>> fetchSongsByArtist(int artistId) async {
    final models = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ARTIST_ID,
      artistId,
    );
    return models.map(_mapSong).toList();
  }

  Future<List<Song>> fetchSongsByAlbum(int albumId) async {
    final models = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID,
      albumId,
    );
    return models.map(_mapSong).toList();
  }

  Uint8ListProvider get artworkProvider => Uint8ListProvider(_audioQuery);

  Song _mapSong(SongModel m) {
    return Song(
      id: m.id,
      title: m.title,
      artist: m.artist ?? 'Unknown Artist',
      album: m.album ?? 'Unknown Album',
      albumId: m.albumId ?? -1,
      artistId: m.artistId ?? -1,
      filePath: m.data,
      duration: Duration(milliseconds: m.duration ?? 0),
      fileSize: m.size,
      dateAdded: DateTime.fromMillisecondsSinceEpoch((m.dateAdded ?? 0) * 1000),
    );
  }
}

class Uint8ListProvider {
  final OnAudioQuery _audioQuery;
  Uint8ListProvider(this._audioQuery);

  Future<Uint8List?> getArtwork(int id) {
    return _audioQuery.queryArtwork(id, ArtworkType.AUDIO);
  }
}
