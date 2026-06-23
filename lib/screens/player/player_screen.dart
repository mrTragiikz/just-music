import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/audio_handler.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final library = context.watch<LibraryProvider>();
    final song = player.currentSong;
    final scheme = Theme.of(context).colorScheme;

    if (song == null) {
      return const Scaffold(body: Center(child: Text('Nothing playing')));
    }

    final isFavorite = library.isFavorite(song.id);
    final duration = player.duration ?? song.duration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < 0) {
            player.next();
          } else if (details.primaryVelocity! > 0) {
            player.previous();
          }
        },
        onDoubleTap: () => library.toggleFavorite(song.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: scheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(Icons.music_note, size: 96, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 36),
              Text(
                song.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                song.artist,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: player.position.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble(),
                  max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) =>
                      player.seek(Duration(milliseconds: value.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(player.position), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                    Text(_formatDuration(duration), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      player.shuffleEnabled ? Icons.shuffle_on_outlined : Icons.shuffle,
                      color: player.shuffleEnabled ? scheme.primary : null,
                    ),
                    onPressed: player.toggleShuffle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 36),
                    onPressed: player.previous,
                  ),
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
                    child: IconButton(
                      iconSize: 40,
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: scheme.onPrimary,
                      ),
                      onPressed: player.togglePlayPause,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 36),
                    onPressed: player.next,
                  ),
                  IconButton(
                    icon: Icon(_repeatIcon(player.repeatMode),
                        color: player.repeatMode == PlayerRepeatMode.off ? null : scheme.primary),
                    onPressed: player.cycleRepeat,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? scheme.error : null,
                    ),
                    onPressed: () => library.toggleFavorite(song.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () {},
                  ),
                  PopupMenuButton<double>(
                    icon: const Icon(Icons.speed),
                    onSelected: player.setSpeed,
                    itemBuilder: (context) => const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        .map((s) => PopupMenuItem(value: s, child: Text('${s}x')))
                        .toList(),
                  ),
                  IconButton(
                    icon: Icon(
                      player.hasSleepTimer ? Icons.bedtime : Icons.bedtime_outlined,
                      color: player.hasSleepTimer ? scheme.primary : null,
                    ),
                    onPressed: () => _showSleepTimerSheet(context, player),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepTimerSheet(BuildContext context, PlayerProvider player) {
    const presets = [
      Duration(minutes: 5),
      Duration(minutes: 15),
      Duration(minutes: 30),
      Duration(minutes: 45),
      Duration(hours: 1),
    ];

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
                child: Text('Sleep Timer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (player.hasSleepTimer)
              ListTile(
                leading: const Icon(Icons.timer_off),
                title: Text(
                  'Stopping at ${_formatClockTime(player.sleepTimerEndTime!)}',
                ),
                trailing: TextButton(
                  onPressed: () {
                    player.cancelSleepTimer();
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ...presets.map((d) => ListTile(
                  title: Text('In ${d.inMinutes} min'),
                  onTap: () {
                    player.setSleepTimerDuration(d);
                    Navigator.pop(sheetContext);
                  },
                )),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Pick a time'),
              onTap: () async {
                final picked = await showTimePicker(
                  context: sheetContext,
                  initialTime: TimeOfDay.now(),
                );
                if (picked == null) return;
                final now = DateTime.now();
                final target = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  picked.hour,
                  picked.minute,
                );
                player.setSleepTimerAt(target);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatClockTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  IconData _repeatIcon(PlayerRepeatMode mode) {
    switch (mode) {
      case PlayerRepeatMode.off:
        return Icons.repeat;
      case PlayerRepeatMode.all:
        return Icons.repeat;
      case PlayerRepeatMode.one:
        return Icons.repeat_one;
    }
  }
}
