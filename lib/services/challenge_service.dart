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

    // Distribution: 65% normal, 15% game, 12% virus start, 8% virus stop, 10% bottoms_up
    final normalCount = (totalCards * 0.55).round();
    final gameCount = (totalCards * 0.15).round();
    final virusCount = (totalCards * 0.15).round();
    final bottomsUpCount = (totalCards * 0.10).round();
    final fillerCount = totalCards - normalCount - gameCount - virusCount - bottomsUpCount;

    // Add normal challenges
    for (int i = 0; i < normalCount; i++) {
      deck.add(_getChallengeByType('normal'));
    }

    // Add game challenges
    for (int i = 0; i < gameCount; i++) {
      deck.add(_getChallengeByType('game'));
    }

    // Add virus challenges (mix of start and stop)
    final virusChallenges = _challenges.where((c) => c.type == 'virus').toList();
    if (virusChallenges.isNotEmpty) {
      final virusStarts = virusChallenges.where((c) => !c.textPT.toLowerCase().contains('acabou') && !c.textPT.toLowerCase().contains('fim')).toList();
      final virusStops = virusChallenges.where((c) => c.textPT.toLowerCase().contains('acabou') || c.textPT.toLowerCase().contains('fim')).toList();

      for (int i = 0; i < virusCount; i++) {
        if (i.isEven && virusStarts.isNotEmpty) {
          deck.add(virusStarts[_random.nextInt(virusStarts.length)]);
        } else if (virusStops.isNotEmpty) {
          deck.add(virusStops[_random.nextInt(virusStops.length)]);
        } else {
          deck.add(_getChallengeByType('virus'));
        }
      }
    }

    // Add bottoms up (rare)
    for (int i = 0; i < bottomsUpCount; i++) {
      deck.add(_getChallengeByType('bottoms_up'));
    }

    // Fill remaining with random challenges
    for (int i = 0; i < fillerCount; i++) {
      deck.add(_challenges[_random.nextInt(_challenges.length)]);
    }

    // Shuffle the deck
    deck.shuffle(_random);

    return deck;
  }

  static List<Challenge> _getDefaultChallenges() {
    return [
      Challenge(id: '1', type: 'normal', textPT: 'Se voce ja mentiu, beba 2 goles', textEN: "If you've lied, take 2 sips", sips: 2),
      Challenge(id: '2', type: 'normal', textPT: 'Se voce ja chegou atrasado, beba 3 goles', textEN: "If you've been late, take 3 sips", sips: 3),
      Challenge(id: '3', type: 'game', textPT: 'Vai passando e listando frutas. Quem errar bebe 2 goles!', textEN: "Pass around naming fruits. Wrong answer drinks 2 sips!", sips: 2),
      Challenge(id: '4', type: 'virus', textPT: 'Agora so pode falar baixo!', textEN: "You can only speak softly now!", sips: 0),
      Challenge(id: '5', type: 'virus', textPT: 'O virus acabou!', textEN: "The virus is over!", sips: 0),
      Challenge(id: '6', type: 'bottoms_up', textPT: 'Bebe tudo!', textEN: "Drink it all!", sips: 0),
    ];
  }
}
