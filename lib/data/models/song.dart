class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int albumId;
  final int artistId;
  final String filePath;
  final Duration duration;
  final int fileSize;
  final DateTime dateAdded;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumId,
    required this.artistId,
    required this.filePath,
    required this.duration,
    required this.fileSize,
    required this.dateAdded,
  });
}
