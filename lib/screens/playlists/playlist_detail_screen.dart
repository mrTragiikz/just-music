import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/playlist.dart';
import '../../data/models/song.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/common/song_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();

    final List<Song> orderedSongs = playlist.songIds
        .map((id) => library.songs.where((s) => s.id == id).firstOrNull)
        .whereType<Song>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: orderedSongs.isEmpty
          ? const Center(child: Text('This playlist is empty'))
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
                            player.playQueue(orderedSongs, 0);
                            library.recordPlay(orderedSongs[0].id);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle'),
                          onPressed: () {
                            final shuffled = [...orderedSongs]..shuffle();
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
                    itemCount: orderedSongs.length,
                    itemBuilder: (context, index) {
                      final song = orderedSongs[index];
                      return SongTile(
                        song: song,
                        isPlaying: player.currentSong?.id == song.id,
                        isFavorite: library.isFavorite(song.id),
                        onTap: () {
                          player.playQueue(orderedSongs, index);
                          library.recordPlay(song.id);
                        },
                        onFavoriteTap: () => library.toggleFavorite(song.id),
                        menuActions: [
                          SongMenuAction(
                            label: 'Remove from Playlist',
                            icon: Icons.playlist_remove,
                            onSelected: () => context
                                .read<PlaylistProvider>()
                                .removeSongFromPlaylist(playlist.id!, song.id),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
