import 'package:hive/hive.dart';
import 'player.dart';

class PlayerGroup extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> playerIds;

  @HiveField(3)
  DateTime createdAt;

  PlayerGroup({
    required this.id,
    required this.name,
    List<String>? playerIds,
    DateTime? createdAt,
  })  : playerIds = playerIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  List<Player> getPlayers(List<Player> allPlayers) {
    return allPlayers.where((p) => playerIds.contains(p.id)).toList();
  }

  void addPlayer(String playerId) {
    if (!playerIds.contains(playerId)) {
      playerIds.add(playerId);
      save();
    }
  }

  void removePlayer(String playerId) {
    playerIds.remove(playerId);
    save();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'playerIds': playerIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlayerGroup.fromMap(Map<String, dynamic> map) {
    return PlayerGroup(
      id: map['id'],
      name: map['name'],
      playerIds: List<String>.from(map['playerIds']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
