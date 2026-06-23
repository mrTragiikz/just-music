import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/playlist_provider.dart';
import 'playlist_detail_screen.dart';
import 'auto_playlist_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().load();
    });
  }

  Future<void> _createPlaylist() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      await context.read<PlaylistProvider>().createPlaylist(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            subtitle: Text('${library.favoriteSongs.length} songs'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AutoPlaylistScreen(
                title: 'Favorites',
                songsProvider: (lib) => lib.favoriteSongs,
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Recently Played'),
            subtitle: Text('${library.recentlyPlayed.length} songs'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AutoPlaylistScreen(
                title: 'Recently Played',
                songsProvider: (lib) => lib.recentlyPlayed,
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.new_releases),
            title: const Text('Recently Added'),
            subtitle: Text('${library.recentlyAdded.length} songs'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AutoPlaylistScreen(
                title: 'Recently Added',
                songsProvider: (lib) => lib.recentlyAdded,
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Most Played'),
            subtitle: Text('${library.mostPlayed.length} songs'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AutoPlaylistScreen(
                title: 'Most Played',
                songsProvider: (lib) => lib.mostPlayed,
              ),
            )),
          ),
          const Divider(),
          if (playlistProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (playlistProvider.playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No custom playlists yet. Tap + to create one.')),
            )
          else
            ...playlistProvider.playlists.map((playlist) => ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songIds.length} songs'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'rename') {
                        final controller = TextEditingController(text: playlist.name);
                        final name = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Rename Playlist'),
                            content: TextField(controller: controller, autofocus: true),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, controller.text.trim()),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                        if (name != null && name.isNotEmpty && context.mounted) {
                          await context.read<PlaylistProvider>().renamePlaylist(playlist.id!, name);
                        }
                      } else if (action == 'delete') {
                        await context.read<PlaylistProvider>().deletePlaylist(playlist.id!);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(playlist: playlist),
                  )),
                )),
        ],
      ),
    );
  }
}
