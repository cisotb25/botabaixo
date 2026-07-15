import 'package:hive/hive.dart';
import 'player.dart';
import 'challenge.dart';

@HiveType(typeId: 2)
class GameRound {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<Player> players;

  @HiveField(2)
  final List<RoundChallenge> challenges;

  @HiveField(3)
  DateTime startedAt;

  @HiveField(4)
  DateTime? endedAt;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  final List<ActiveVirus> activeViruses;

  GameRound({
    required this.id,
    required this.players,
    List<RoundChallenge>? challenges,
    DateTime? startedAt,
    this.endedAt,
    this.isActive = true,
    List<ActiveVirus>? activeViruses,
  })  : challenges = challenges ?? [],
        activeViruses = activeViruses ?? [],
        startedAt = startedAt ?? DateTime.now();

  int get totalSips {
    return challenges.fold(0, (sum, c) => sum + c.challenge.sips);
  }

  int get completedChallenges {
    return challenges.where((c) => c.isCompleted).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'players': players.map((p) => p.toMap()).toList(),
      'challenges': challenges.map((c) => c.toMap()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'isActive': isActive,
      'activeViruses': activeViruses.map((v) => v.toMap()).toList(),
    };
  }

  factory GameRound.fromMap(Map<String, dynamic> map) {
    return GameRound(
      id: map['id'],
      players: (map['players'] as List).map((p) => Player.fromMap(p)).toList(),
      challenges: (map['challenges'] as List)
          .map((c) => RoundChallenge.fromMap(c))
          .toList(),
      startedAt: DateTime.parse(map['startedAt']),
      endedAt: map['endedAt'] != null ? DateTime.parse(map['endedAt']) : null,
      isActive: map['isActive'],
      activeViruses: map['activeViruses'] != null
          ? (map['activeViruses'] as List)
              .map((v) => ActiveVirus.fromMap(v))
              .toList()
          : [],
    );
  }
}

@HiveType(typeId: 3)
class RoundChallenge {
  @HiveField(0)
  final Challenge challenge;

  @HiveField(1)
  final Player assignedPlayer;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime? completedAt;

  RoundChallenge({
    required this.challenge,
    required this.assignedPlayer,
    this.isCompleted = false,
    this.completedAt,
  });

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'challenge': challenge.toMap(),
      'assignedPlayer': assignedPlayer.toMap(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory RoundChallenge.fromMap(Map<String, dynamic> map) {
    return RoundChallenge(
      challenge: Challenge.fromMap(map['challenge']),
      assignedPlayer: Player.fromMap(map['assignedPlayer']),
      isCompleted: map['isCompleted'],
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}

class ActiveVirus {
  final String id;
  final String text;
  final Player assignedPlayer;
  final DateTime startedAt;
  final int duration;
  int roundsRemaining;

  ActiveVirus({
    required this.id,
    required this.text,
    required this.assignedPlayer,
    this.duration = 10,
    int? roundsRemaining,
    DateTime? startedAt,
  })  : roundsRemaining = roundsRemaining ?? duration,
        startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'assignedPlayer': assignedPlayer.toMap(),
      'startedAt': startedAt.toIso8601String(),
      'duration': duration,
      'roundsRemaining': roundsRemaining,
    };
  }

  factory ActiveVirus.fromMap(Map<String, dynamic> map) {
    return ActiveVirus(
      id: map['id'],
      text: map['text'],
      assignedPlayer: Player.fromMap(map['assignedPlayer']),
      startedAt: DateTime.parse(map['startedAt']),
      duration: map['duration'] ?? 10,
      roundsRemaining: map['roundsRemaining'] ?? map['duration'] ?? 10,
    );
  }
}
