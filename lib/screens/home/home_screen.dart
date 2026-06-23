import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../songs/songs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _playSong(BuildContext context, List<Song> songs, int index) {
    context.read<PlayerProvider>().playQueue(songs, index);
    context.read<LibraryProvider>().recordPlay(songs[index].id);
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Just Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SongsScreen()),
            ),
          ),
        ],
      ),
      body: library.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: library.scanLibrary,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play All'),
                            onPressed: library.songs.isEmpty
                                ? null
                                : () => _playSong(context, library.songs, 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Shuffle All'),
                            onPressed: library.songs.isEmpty
                                ? null
                                : () {
                                    final shuffled = [...library.songs]..shuffle();
                                    _playSong(context, shuffled, 0);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HomeSection(
                    title: 'Recently Played',
                    songs: library.recentlyPlayed,
                    onTapSong: (songs, i) => _playSong(context, songs, i),
                  ),
                  _HomeSection(
                    title: 'Recently Added',
                    songs: library.recentlyAdded,
                    onTapSong: (songs, i) => _playSong(context, songs, i),
                  ),
                  _HomeSection(
                    title: 'Most Played',
                    songs: library.mostPlayed,
                    onTapSong: (songs, i) => _playSong(context, songs, i),
                  ),
                  _HomeSection(
                    title: 'Favorite Songs',
                    songs: library.favoriteSongs,
                    onTapSong: (songs, i) => _playSong(context, songs, i),
                  ),
                ],
              ),
            ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  final String title;
  final List<Song> songs;
  final void Function(List<Song> songs, int index) onTapSong;

  const _HomeSection({
    required this.title,
    required this.songs,
    required this.onTapSong,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () => onTapSong(songs, index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 112,
                          height: 100,
                          color: scheme.surfaceContainerHighest,
                          child: Icon(Icons.music_note, color: scheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
