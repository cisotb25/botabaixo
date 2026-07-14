import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String pronoun; // 'ele', 'ela', 'elu', 'he', 'she', 'they'

  @HiveField(3)
  DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.pronoun,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get pronounPT {
    switch (pronoun) {
      case 'ele':
        return 'Ele';
      case 'ela':
        return 'Ela';
      case 'elu':
        return 'Elu';
      default:
        return 'Ele';
    }
  }

  String get pronounEN {
    switch (pronoun) {
      case 'he':
        return 'He';
      case 'she':
        return 'She';
      case 'they':
        return 'They';
      default:
        return 'He';
    }
  }

  String get possessivePT {
    switch (pronoun) {
      case 'ele':
        return 'Dele';
      case 'ela':
        return 'Dela';
      case 'elu':
        return 'Delu';
      default:
        return 'Dele';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pronoun': pronoun,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      pronoun: map['pronoun'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
