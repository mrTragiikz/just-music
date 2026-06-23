import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../providers/library_provider.dart';
import 'artist_detail_screen.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  String _query = '';
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final artists = _query.isEmpty
        ? library.artists
        : library.artists
            .where((a) => (a.artist).toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search artists...', border: InputBorder.none),
                onChanged: (value) => setState(() => _query = value),
              )
            : const Text('Artists'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              _query = '';
            }),
          ),
        ],
      ),
      body: library.isLoading
          ? const Center(child: CircularProgressIndicator())
          : artists.isEmpty
              ? const Center(child: Text('No artists found'))
              : ListView.builder(
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    final ArtistModel artist = artists[index];
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text(artist.artist),
                      subtitle: Text('${artist.numberOfTracks ?? 0} songs'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArtistDetailScreen(artist: artist),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
