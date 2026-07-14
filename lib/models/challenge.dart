import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Challenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category; // 'bebida', 'verdade', 'coragem', 'grupo'

  @HiveField(2)
  final String difficulty; // 'facil', 'medio', 'dificil', 'extremo'

  @HiveField(3)
  final int shots;

  @HiveField(4)
  final String textPT;

  @HiveField(5)
  final String textEN;

  Challenge({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.shots,
    required this.textPT,
    required this.textEN,
  });

  String getCategoryIcon() {
    switch (category) {
      case 'bebida':
        return '🍺';
      case 'verdade':
        return '💬';
      case 'coragem':
        return '💪';
      case 'grupo':
        return '👥';
      default:
        return '❓';
    }
  }

  String getCategoryNamePT() {
    switch (category) {
      case 'bebida':
        return 'Bebida';
      case 'verdade':
        return 'Verdade';
      case 'coragem':
        return 'Coragem';
      case 'grupo':
        return 'Grupo';
      default:
        return 'Desconhecido';
    }
  }

  String getCategoryNameEN() {
    switch (category) {
      case 'bebida':
        return 'Drink';
      case 'verdade':
        return 'Truth';
      case 'coragem':
        return 'Courage';
      case 'grupo':
        return 'Group';
      default:
        return 'Unknown';
    }
  }

  String getDifficultyColor() {
    switch (difficulty) {
      case 'facil':
        return '#4CAF50'; // Green
      case 'medio':
        return '#FF9800'; // Orange
      case 'dificil':
        return '#F44336'; // Red
      case 'extremo':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'shots': shots,
      'text_pt': textPT,
      'text_en': textEN,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      category: map['category'],
      difficulty: map['difficulty'],
      shots: map['shots'],
      textPT: map['text_pt'],
      textEN: map['text_en'],
    );
  }
}
