import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/challenge.dart';
import 'storage_service.dart';

class ChallengeService {
  static List<Challenge> _challenges = [];
  static final _random = Random();

  static List<Challenge> get challenges => _challenges;

  static Future<void> loadChallenges() async {
    try {
      _challenges = StorageService.getAllChallenges();
      if (_challenges.isEmpty) {
        await _loadFromJson();
      }
    } catch (e) {
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
    } catch (e) {
      _challenges = _getDefaultChallenges();
    }
  }

  static Challenge? getRandomChallenge({String? type}) {
    List<Challenge> filtered = _challenges;

    if (type != null) {
      filtered = filtered.where((c) => c.type == type).toList();
    }

    if (filtered.isEmpty) return null;
    return filtered[_random.nextInt(filtered.length)];
  }

  static Challenge _getChallengeByType(String type) {
    final filtered = _challenges.where((c) => c.type == type).toList();
    if (filtered.isEmpty) {
      return _challenges[_random.nextInt(_challenges.length)];
    }
    return filtered[_random.nextInt(filtered.length)];
  }

  static List<Challenge> generateDeck(int totalCards) {
    final List<Challenge> deck = [];

    // Distribution: 40% normal, 30% game, 20% virus, 10% bottoms_up
    final normalCount = (totalCards * 0.40).round();
    final gameCount = (totalCards * 0.30).round();
    final virusCount = (totalCards * 0.20).round();
    final bottomsUpCount = totalCards - normalCount - gameCount - virusCount;

    // Add normal challenges
    for (int i = 0; i < normalCount; i++) {
      deck.add(_getChallengeByType('normal'));
    }

    // Add game challenges
    for (int i = 0; i < gameCount; i++) {
      deck.add(_getChallengeByType('game'));
    }

    // Add virus challenges (start cards first, end cards later)
    final virusStarts = _challenges.where((c) => c.type == 'virus_start').toList();
    final virusEnds = _challenges.where((c) => c.type == 'virus_end').toList();

    if (virusCount > 0 && virusStarts.isNotEmpty) {
      // Add start cards in first half of virus section
      final halfVirus = (virusCount / 2).ceil();
      for (int i = 0; i < halfVirus && i < virusStarts.length; i++) {
        deck.add(virusStarts[_random.nextInt(virusStarts.length)]);
      }

      // Add end cards in second half (ensures start comes before end)
      final remainingVirus = virusCount - halfVirus;
      if (virusEnds.isNotEmpty) {
        for (int i = 0; i < remainingVirus; i++) {
          deck.add(virusEnds[_random.nextInt(virusEnds.length)]);
        }
      }
    }

    // Add bottoms up
    for (int i = 0; i < bottomsUpCount; i++) {
      deck.add(_getChallengeByType('bottoms_up'));
    }

    // Shuffle the deck
    deck.shuffle(_random);

    return deck;
  }

  static List<Challenge> _getDefaultChallenges() {
    return [
      Challenge(id: '1', type: 'normal', textPT: 'Se você já mentiu, beba 2 goles', textEN: "If you've lied, take 2 sips", sips: 2),
      Challenge(id: '2', type: 'normal', textPT: 'Se você já chegou atrasado, beba 3 goles', textEN: "If you've been late, take 3 sips", sips: 3),
      Challenge(id: '3', type: 'game', textPT: 'Vai passando e listando frutas. Quem errar bebe 2 goles!', textEN: "Pass around naming fruits. Wrong answer drinks 2 sips!", sips: 2),
      Challenge(id: '4', type: 'virus_start', textPT: 'Agora só pode falar baixo!', textEN: "You can only speak softly now!"},
      Challenge(id: '5', type: 'virus_end', textPT: 'O vírus acabou!', textEN: "The virus is over!"},
      Challenge(id: '6', type: 'bottoms_up', textPT: 'Bebe tudo!', textEN: "Drink it all!"},
    ];
  }
}
