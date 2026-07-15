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
    // Distribution: 40% normal, 30% game, 20% virus, 10% bottoms_up
    final normalCount = (totalCards * 0.40).round();
    final gameCount = (totalCards * 0.30).round();
    final virusCount = (totalCards * 0.20).round();
    final bottomsUpCount = totalCards - normalCount - gameCount - virusCount;

    // Build non-virus cards (shuffled)
    final nonVirusDeck = <Challenge>[];
    for (int i = 0; i < normalCount; i++) {
      nonVirusDeck.add(_getChallengeByType('normal'));
    }
    for (int i = 0; i < gameCount; i++) {
      nonVirusDeck.add(_getChallengeByType('game'));
    }
    for (int i = 0; i < bottomsUpCount; i++) {
      nonVirusDeck.add(_getChallengeByType('bottoms_up'));
    }
    nonVirusDeck.shuffle(_random);

    // Add virus_start cards only (no virus_end - they auto-expire after 5-15 rounds)
    final virusStarts = _challenges.where((c) => c.type == 'virus_start').toList();
    final virusCards = <Challenge>[];
    for (int i = 0; i < virusCount && virusStarts.isNotEmpty; i++) {
      virusCards.add(virusStarts[_random.nextInt(virusStarts.length)]);
    }

    // Insert virus cards at random positions in the deck
    final deck = List<Challenge>.from(nonVirusDeck);
    for (final virus in virusCards) {
      final maxIndex = deck.length;
      final insertIndex = _random.nextInt(maxIndex + 1);
      deck.insert(insertIndex, virus);
    }

    return deck;
  }

  static List<Challenge> _getDefaultChallenges() {
    return [
      Challenge(id: '1', type: 'normal', textPT: 'Se você já mentiu, beba 2 goles', textEN: "If you've lied, take 2 sips", sips: 2),
      Challenge(id: '2', type: 'normal', textPT: 'Se você já chegou atrasado, beba 3 goles', textEN: "If you've been late, take 3 sips", sips: 3),
      Challenge(id: '3', type: 'game', textPT: 'Vai passando e listando frutas. Quem errar bebe 2 goles!', textEN: "Pass around naming fruits. Wrong answer drinks 2 sips!", sips: 2),
      Challenge(id: '4', type: 'virus_start', textPT: 'Agora só pode falar baixo!', textEN: "You can only speak softly now!"),
      Challenge(id: '5', type: 'virus_end', textPT: 'O vírus acabou!', textEN: "The virus is over!"),
      Challenge(id: '6', type: 'bottoms_up', textPT: 'Bebe tudo!', textEN: "Drink it all!"),
    ];
  }
}
