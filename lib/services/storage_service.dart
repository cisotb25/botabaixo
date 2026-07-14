import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/challenge.dart';
import '../models/game_round.dart';
import '../models/player_adapter.dart';
import '../models/challenge_adapter.dart';
import '../models/game_round_adapter.dart';

class StorageService {
  static const String playersBox = 'players';
  static const String challengesBox = 'challenges';
  static const String gameRoundsBox = 'game_rounds';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(ChallengeAdapter());
    Hive.registerAdapter(GameRoundAdapter());
    Hive.registerAdapter(RoundChallengeAdapter());

    // Open boxes
    await Hive.openBox<Player>(playersBox);
    await Hive.openBox<Challenge>(challengesBox);
    await Hive.openBox<GameRound>(gameRoundsBox);
    await Hive.openBox(settingsBox);
  }

  // Player operations
  static Box<Player> getPlayersBox() {
    return Hive.box<Player>(playersBox);
  }

  static List<Player> getAllPlayers() {
    return getPlayersBox().values.toList();
  }

  static Future<void> addPlayer(Player player) async {
    await getPlayersBox().put(player.id, player);
  }

  static Future<void> updatePlayer(Player player) async {
    await getPlayersBox().put(player.id, player);
  }

  static Future<void> deletePlayer(String id) async {
    await getPlayersBox().delete(id);
  }

  static Player? getPlayer(String id) {
    return getPlayersBox().get(id);
  }

  // Challenge operations
  static Box<Challenge> getChallengesBox() {
    return Hive.box<Challenge>(challengesBox);
  }

  static List<Challenge> getAllChallenges() {
    return getChallengesBox().values.toList();
  }

  static List<Challenge> getChallengesByCategory(String category) {
    return getAllChallenges()
        .where((challenge) => challenge.category == category)
        .toList();
  }

  static List<Challenge> getChallengesByDifficulty(String difficulty) {
    return getAllChallenges()
        .where((challenge) => challenge.difficulty == difficulty)
        .toList();
  }

  static Future<void> addChallenge(Challenge challenge) async {
    await getChallengesBox().put(challenge.id, challenge);
  }

  static Future<void> addAllChallenges(List<Challenge> challenges) async {
    for (var challenge in challenges) {
      await getChallengesBox().put(challenge.id, challenge);
    }
  }

  // Game round operations
  static Box<GameRound> getGameRoundsBox() {
    return Hive.box<GameRound>(gameRoundsBox);
  }

  static List<GameRound> getAllGameRounds() {
    return getGameRoundsBox().values.toList();
  }

  static Future<void> addGameRound(GameRound round) async {
    await getGameRoundsBox().put(round.id, round);
  }

  static Future<void> updateGameRound(GameRound round) async {
    await getGameRoundsBox().put(round.id, round);
  }

  static Future<void> deleteGameRound(String id) async {
    await getGameRoundsBox().delete(id);
  }

  static GameRound? getGameRound(String id) {
    return getGameRoundsBox().get(id);
  }

  // Settings operations
  static Box getSettingsBox() {
    return Hive.box(settingsBox);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return getSettingsBox().get(key, defaultValue: defaultValue);
  }

  static Future<void> setSetting(String key, dynamic value) async {
    await getSettingsBox().put(key, value);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await getPlayersBox().clear();
    await getChallengesBox().clear();
    await getGameRoundsBox().clear();
    await getSettingsBox().clear();
  }
}
