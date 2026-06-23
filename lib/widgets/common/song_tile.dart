import 'package:flutter/material.dart';
import '../../data/models/song.dart';

class SongMenuAction {
  final String label;
  final IconData icon;
  final VoidCallback onSelected;

  const SongMenuAction({required this.label, required this.icon, required this.onSelected});
}

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isFavorite;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;
  final List<SongMenuAction> menuActions;

  const SongTile({
    super.key,
    required this.song,
    this.isPlaying = false,
    this.isFavorite = false,
    this.selected = false,
    this.selectionMode = false,
    required this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
    this.menuActions = const [],
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.3),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 48,
          height: 48,
          color: scheme.surfaceContainerHighest,
          child: Icon(
            selectionMode && selected ? Icons.check_circle : Icons.music_note,
            color: isPlaying ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying ? scheme.primary : null,
          fontWeight: isPlaying ? FontWeight.bold : null,
        ),
      ),
      subtitle: Text(
        '${song.artist} • ${_formatDuration(song.duration)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: selectionMode
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? scheme.error : null,
                  ),
                  onPressed: onFavoriteTap,
                ),
                if (menuActions.isNotEmpty)
                  PopupMenuButton<SongMenuAction>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) => action.onSelected(),
                    itemBuilder: (context) => menuActions
                        .map((action) => PopupMenuItem(
                              value: action,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(action.icon),
                                title: Text(action.label),
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
    );
  }
}
