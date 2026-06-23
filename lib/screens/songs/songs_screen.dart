import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/song.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/common/song_tile.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  bool _searching = false;
  String _query = '';
  final Set<int> _selected = {};

  bool get _selectionMode => _selected.isNotEmpty;

  void _playSong(List<Song> songs, int index) {
    final player = context.read<PlayerProvider>();
    final library = context.read<LibraryProvider>();
    player.playQueue(songs, index);
    library.recordPlay(songs[index].id);
  }

  void _showSortSheet() {
    final library = context.read<LibraryProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...SongSortBy.values.map((sort) => RadioListTile<SongSortBy>(
                    title: Text(_sortLabel(sort)),
                    value: sort,
                    groupValue: library.sortBy,
                    onChanged: (value) {
                      library.applySort(value);
                      Navigator.pop(context);
                    },
                  )),
              SwitchListTile(
                title: const Text('Ascending'),
                value: library.sortAscending,
                onChanged: (value) {
                  library.applySort(null, value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToPlaylist(Song song) async {
    final playlistProvider = context.read<PlaylistProvider>();
    await playlistProvider.load();
    if (!mounted) return;
    final playlists = playlistProvider.playlists;
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No playlists yet. Create one from the Playlists tab.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Add to Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            ...playlists.map((playlist) => ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(playlist.name),
                  onTap: () async {
                    await playlistProvider.addSongToPlaylist(playlist.id!, song.id);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _sortLabel(SongSortBy sort) {
    switch (sort) {
      case SongSortBy.name:
        return 'Name';
      case SongSortBy.artist:
        return 'Artist';
      case SongSortBy.album:
        return 'Album';
      case SongSortBy.dateAdded:
        return 'Date Added';
      case SongSortBy.duration:
        return 'Duration';
      case SongSortBy.fileSize:
        return 'File Size';
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();

    final songs = _query.isEmpty ? library.songs : library.searchSongs(_query);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search songs...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _query = value),
              )
            : _selectionMode
                ? Text('${_selected.length} selected')
                : const Text('Songs'),
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    for (final id in _selected) {
                      library.toggleFavorite(id);
                    }
                    setState(() => _selected.clear());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selected.clear()),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(_searching ? Icons.close : Icons.search),
                  onPressed: () => setState(() {
                    _searching = !_searching;
                    _query = '';
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _showSortSheet,
                ),
              ],
      ),
      body: library.isLoading
          ? const Center(child: CircularProgressIndicator())
          : library.permissionDenied
              ? _PermissionDeniedView(onRetry: library.scanLibrary)
              : songs.isEmpty
                  ? const Center(child: Text('No songs found'))
                  : Column(
                      children: [
                        if (!_selectionMode && _query.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Play All'),
                                    onPressed: () => _playSong(songs, 0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.shuffle),
                                    label: const Text('Shuffle'),
                                    onPressed: () {
                                      final shuffled = [...songs]..shuffle();
                                      _playSong(shuffled, 0);
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
                              final isCurrentlyPlaying =
                                  player.currentSong?.id == song.id;
                              return SongTile(
                                song: song,
                                isPlaying: isCurrentlyPlaying,
                                isFavorite: library.isFavorite(song.id),
                                selected: _selected.contains(song.id),
                                selectionMode: _selectionMode,
                                onTap: () {
                                  if (_selectionMode) {
                                    setState(() {
                                      if (!_selected.remove(song.id)) {
                                        _selected.add(song.id);
                                      }
                                    });
                                  } else {
                                    _playSong(songs, index);
                                  }
                                },
                                onLongPress: () =>
                                    setState(() => _selected.add(song.id)),
                                onFavoriteTap: () => library.toggleFavorite(song.id),
                                menuActions: [
                                  SongMenuAction(
                                    label: 'Add to Playlist',
                                    icon: Icons.playlist_add,
                                    onSelected: () => _addToPlaylist(song),
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

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Music access permission is required to scan your device for songs.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Grant Permission')),
          ],
        ),
      ),
    );
  }
}
