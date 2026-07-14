import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/challenge.dart';
import 'storage_service.dart';

class ChallengeService {
  static List<Challenge> _challenges = [];

  static List<Challenge> get challenges => _challenges;

  static Future<void> loadChallenges() async {
    try {
      // Try to load from local storage first
      _challenges = StorageService.getAllChallenges();

      // If no challenges in storage, load from JSON
      if (_challenges.isEmpty) {
        await _loadFromJson();
      }
    } catch (e) {
      // If error, load from JSON
      await _loadFromJson();
    }
  }

  static Future<void> _loadFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/challenges.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> challengesJson = jsonData['challenges'];

      _challenges = challengesJson
          .map((challengeJson) => Challenge.fromMap(challengeJson))
          .toList();

      // Save to local storage
      await StorageService.addAllChallenges(_challenges);
    } catch (e) {
      // If JSON loading fails, use default challenges
      _challenges = _getDefaultChallenges();
      await StorageService.addAllChallenges(_challenges);
    }
  }

  static Challenge? getRandomChallenge({String? category, String? difficulty}) {
    List<Challenge> filteredChallenges = _challenges;

    if (category != null) {
      filteredChallenges = filteredChallenges
          .where((c) => c.category == category)
          .toList();
    }

    if (difficulty != null) {
      filteredChallenges = filteredChallenges
          .where((c) => c.difficulty == difficulty)
          .toList();
    }

    if (filteredChallenges.isEmpty) {
      return null;
    }

    final random = DateTime.now().millisecondsSinceEpoch;
    return filteredChallenges[random % filteredChallenges.length];
  }

  static List<Challenge> getRandomChallenges(int count,
      {String? category, String? difficulty}) {
    List<Challenge> filteredChallenges = List.from(_challenges);

    if (category != null) {
      filteredChallenges = filteredChallenges
          .where((c) => c.category == category)
          .toList();
    }

    if (difficulty != null) {
      filteredChallenges = filteredChallenges
          .where((c) => c.difficulty == difficulty)
          .toList();
    }

    filteredChallenges.shuffle();

    return filteredChallenges.take(count).toList();
  }

  static List<Challenge> _getDefaultChallenges() {
    return [
      Challenge(
        id: '1',
        category: 'bebida',
        difficulty: 'facil',
        shots: 1,
        textPT: 'Beba um gole',
        textEN: 'Take a sip',
      ),
      Challenge(
        id: '2',
        category: 'bebida',
        difficulty: 'facil',
        shots: 1,
        textPT: 'Brinde com alguém',
        textEN: 'Toast with someone',
      ),
      Challenge(
        id: '3',
        category: 'bebida',
        difficulty: 'facil',
        shots: 1,
        textPT: 'Faça um brinde criativo',
        textEN: 'Make a creative toast',
      ),
      Challenge(
        id: '4',
        category: 'bebida',
        difficulty: 'medio',
        shots: 2,
        textPT: 'Beba dois goles',
        textEN: 'Take two sips',
      ),
      Challenge(
        id: '5',
        category: 'verdade',
        difficulty: 'medio',
        shots: 2,
        textPT: 'Qual foi a sua maior vergonha?',
        textEN: "What's your biggest embarrassment?",
      ),
      Challenge(
        id: '6',
        category: 'verdade',
        difficulty: 'medio',
        shots: 2,
        textPT: 'Conte uma mentira que já contou',
        textEN: "Tell a lie you've told",
      ),
      Challenge(
        id: '7',
        category: 'verdade',
        difficulty: 'medio',
        shots: 2,
        textPT: 'Qual é o seu maior medo?',
        textEN: "What's your biggest fear?",
      ),
      Challenge(
        id: '8',
        category: 'coragem',
        difficulty: 'dificil',
        shots: 3,
        textPT: 'Imite um animal por 30 segundos',
        textEN: 'Imitate an animal for 30 seconds',
      ),
      Challenge(
        id: '9',
        category: 'coragem',
        difficulty: 'dificil',
        shots: 3,
        textPT: 'Cante uma música popular',
        textEN: 'Sing a popular song',
      ),
      Challenge(
        id: '10',
        category: 'coragem',
        difficulty: 'dificil',
        shots: 3,
        textPT: 'Faça uma dança ridícula',
        textEN: 'Do a ridiculous dance',
      ),
      Challenge(
        id: '11',
        category: 'grupo',
        difficulty: 'extremo',
        shots: 4,
        textPT: 'Todos bebem!',
        textEN: 'Everyone drinks!',
      ),
      Challenge(
        id: '12',
        category: 'grupo',
        difficulty: 'extremo',
        shots: 4,
        textPT: 'O grupo escolhe quem bebe',
        textEN: 'The group chooses who drinks',
      ),
      Challenge(
        id: '13',
        category: 'grupo',
        difficulty: 'extremo',
        shots: 4,
        textPT: 'Todos fazem uma rodada de shots',
        textEN: 'Everyone does a round of shots',
      ),
      Challenge(
        id: '14',
        category: 'bebida',
        difficulty: 'facil',
        shots: 1,
        textPT: 'Tome um drink diferente',
        textEN: 'Take a different drink',
      ),
      Challenge(
        id: '15',
        category: 'bebida',
        difficulty: 'medio',
        shots: 2,
        textPT: 'Misture duas bebidas e beba',
        textEN: 'Mix two drinks and have them',
      ),
      Challenge(
        id: '16',
        category: 'verdade',
        difficulty: 'dificil',
        shots: 3,
        textPT: 'Revele algo que ninguém sabe sobre você',
        textEN: 'Reveal something no one knows about you',
      ),
      Challenge(
        id: '17',
        category: 'coragem',
        difficulty: 'dificil',
        shots: 3,
        textPT: 'Ligue para alguém e diga "eu te amo"',
        textEN: "Call someone and say 'I love you'",
      ),
      Challenge(
        id: '18',
        category: 'coragem',
        difficulty: 'facil',
        shots: 1,
        textPT: 'Poste algo engraçado nas redes sociais',
        textEN: 'Post something funny on social media',
      ),
      Challenge(
        id: '19',
        category: 'grupo',
        difficulty: 'extremo',
        shots: 4,
        textPT: 'O último a chegar na mesa bebe',
        textEN: 'The last one to arrive at the table drinks',
      ),
      Challenge(
        id: '20',
        category: 'bebida',
        difficulty: 'facil',
        shots: 1,
        textPT: 'Escolha alguém para beber com você',
        textEN: 'Choose someone to drink with you',
      ),
    ];
  }
}
