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
      case 'desafio':
        return '💪';
      case 'verdade':
        return '💬';
      case 'seria_ou_beberia':
        return '🤔';
      case 'penalidade_max':
        return '☠️';
      case 'regra':
        return '📏';
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
      case 'desafio':
        return 'Desafio';
      case 'verdade':
        return 'Verdade';
      case 'seria_ou_beberia':
        return 'Seria ou Beberia';
      case 'penalidade_max':
        return 'Penalidade Maxima';
      case 'regra':
        return 'Regra';
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
      case 'desafio':
        return 'Challenge';
      case 'verdade':
        return 'Truth';
      case 'seria_ou_beberia':
        return 'Would You Rather';
      case 'penalidade_max':
        return 'Maximum Penalty';
      case 'regra':
        return 'Rule';
      case 'grupo':
        return 'Group';
      default:
        return 'Unknown';
    }
  }

  int getCategoryColorValue() {
    switch (category) {
      case 'desafio':
        return 0xFF4CAF50; // Green
      case 'verdade':
        return 0xFF2196F3; // Blue
      case 'seria_ou_beberia':
        return 0xFF9C27B0; // Purple
      case 'penalidade_max':
        return 0xFFF44336; // Red
      case 'regra':
        return 0xFFFFEB3B; // Yellow
      case 'bebida':
        return 0xFFFF6D00; // Orange
      case 'grupo':
        return 0xFFFF6D00; // Orange
      default:
        return 0xFF757575; // Grey
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
