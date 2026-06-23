import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/common/song_tile.dart';

class AutoPlaylistScreen extends StatelessWidget {
  final String title;
  final List<Song> Function(LibraryProvider) songsProvider;

  const AutoPlaylistScreen({
    super.key,
    required this.title,
    required this.songsProvider,
  });

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final songs = songsProvider(library);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: songs.isEmpty
          ? Center(child: Text('No songs in $title yet'))
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
                          onPressed: () {
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
                          onPressed: () {
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
