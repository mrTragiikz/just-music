class Playlist {
  final int? id;
  final String name;
  final List<int> songIds;
  final DateTime createdAt;

  const Playlist({
    this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  Playlist copyWith({int? id, String? name, List<int>? songIds}) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'songIds': songIds.join(','),
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Playlist.fromMap(Map<String, dynamic> map) {
    final rawIds = map['songIds'] as String;
    return Playlist(
      id: map['id'] as int,
      name: map['name'] as String,
      songIds: rawIds.isEmpty
          ? []
          : rawIds.split(',').map((e) => int.parse(e)).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
