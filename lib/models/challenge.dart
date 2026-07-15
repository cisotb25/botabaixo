import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Challenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'normal', 'game', 'virus', 'bottoms_up'

  @HiveField(2)
  final String textPT;

  @HiveField(3)
  final String textEN;

  @HiveField(4)
  final int sips;

  @HiveField(5)
  final bool giveSips; // if true, player gives sips instead of drinking

  @HiveField(6)
  final int giveSipsAmount;

  Challenge({
    required this.id,
    required this.type,
    required this.textPT,
    required this.textEN,
    this.sips = 0,
    this.giveSips = false,
    this.giveSipsAmount = 0,
  });

  bool get isVirus => type == 'virus' || type == 'virus_start' || type == 'virus_end';
  bool get isVirusStart => type == 'virus_start';
  bool get isVirusEnd => type == 'virus_end';
  bool get isBottomsUp => type == 'bottoms_up';
  bool get isGame => type == 'game';
  bool get isNormal => type == 'normal';

  String get icon {
    switch (type) {
      case 'normal':
        return '🍺';
      case 'game':
        return '🎮';
      case 'virus_start':
        return '🦠';
      case 'virus_end':
        return '🦠';
      case 'virus':
        return '🦠';
      case 'bottoms_up':
        return ' bottoms_up';
      default:
        return '❓';
    }
  }

  String get typeNamePT {
    switch (type) {
      case 'normal':
        return 'Normal';
      case 'game':
        return 'Jogo';
      case 'virus_start':
        return 'Virus';
      case 'virus_end':
        return 'Virus';
      case 'virus':
        return 'Virus';
      case 'bottoms_up':
        return 'Fundo pra Cima!';
      default:
        return 'Desconhecido';
    }
  }

  String get typeNameEN {
    switch (type) {
      case 'normal':
        return 'Normal';
      case 'game':
        return 'Game';
      case 'virus_start':
        return 'Virus';
      case 'virus_end':
        return 'Virus';
      case 'virus':
        return 'Virus';
      case 'bottoms_up':
        return 'Bottoms Up!';
      default:
        return 'Unknown';
    }
  }

  int get colorValue {
    switch (type) {
      case 'normal':
        return 0xFF4CAF50; // Green
      case 'game':
        return 0xFF2196F3; // Blue
      case 'virus':
        return 0xFF9C27B0; // Purple
      case 'bottoms_up':
        return 0xFFF44336; // Red
      default:
        return 0xFF757575; // Grey
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'text_pt': textPT,
      'text_en': textEN,
      'sips': sips,
      'give_sips': giveSips,
      'give_sips_amount': giveSipsAmount,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'].toString(),
      type: map['type'],
      textPT: map['text_pt'],
      textEN: map['text_en'],
      sips: map['sips'] ?? 0,
      giveSips: map['give_sips'] ?? false,
      giveSipsAmount: map['give_sips_amount'] ?? 0,
    );
  }

  String getText(String playerName, {String? targetName}) {
    String text = textPT;
    text = text.replaceAll('{player}', playerName);
    if (targetName != null) {
      text = text.replaceAll('{target}', targetName);
    }
    return text;
  }
}
