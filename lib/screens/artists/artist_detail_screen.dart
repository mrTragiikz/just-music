import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../data/models/song.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/common/song_tile.dart';

class ArtistDetailScreen extends StatefulWidget {
  final ArtistModel artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  List<Song>? _songs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final library = context.read<LibraryProvider>();
    final songs = await library.service.fetchSongsByArtist(widget.artist.id);
    if (mounted) setState(() => _songs = songs);
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final songs = _songs;

    return Scaffold(
      appBar: AppBar(title: Text(widget.artist.artist)),
      body: songs == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play All'),
                          onPressed: songs.isEmpty
                              ? null
                              : () {
                                  player.playQueue(songs, 0);
                                  library.recordPlay(songs[0].id);
                                },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle'),
                          onPressed: songs.isEmpty
                              ? null
                              : () {
                                  final shuffled = [...songs]..shuffle();
                                  player.playQueue(shuffled, 0);
                                  library.recordPlay(shuffled[0].id);
                                },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongTile(
                        song: song,
                        isPlaying: player.currentSong?.id == song.id,
                        isFavorite: library.isFavorite(song.id),
                        onTap: () {
                          player.playQueue(songs, index);
                          library.recordPlay(song.id);
                        },
                        onFavoriteTap: () => library.toggleFavorite(song.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
