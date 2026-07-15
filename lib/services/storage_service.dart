import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/challenge.dart';
import '../models/game_round.dart';
import '../models/player_group.dart';
import '../models/player_adapter.dart';
import '../models/challenge_adapter.dart';
import '../models/game_round_adapter.dart';
import '../models/player_group_adapter.dart';
import '../models/active_virus_adapter.dart';
import 'firebase_service.dart';
import '../utils/logger.dart';

class StorageService {
  static const String playersBox = 'players';
  static const String challengesBox = 'challenges';
  static const String gameRoundsBox = 'game_rounds';
  static const String settingsBox = 'settings';
  static const String groupsBox = 'groups';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(ChallengeAdapter());
    Hive.registerAdapter(GameRoundAdapter());
    Hive.registerAdapter(RoundChallengeAdapter());
    Hive.registerAdapter(PlayerGroupAdapter());
    Hive.registerAdapter(ActiveVirusAdapter());

    // Clear old game rounds to avoid adapter conflicts
    try {
      await Hive.openBox<GameRound>(gameRoundsBox);
      await Hive.box<GameRound>(gameRoundsBox).clear();
      await Hive.openBox<Challenge>(challengesBox);
      await Hive.box<Challenge>(challengesBox).clear();
    } catch (e) {
      // Box might not exist yet, that's fine
    }

    // Open boxes
    await Hive.openBox<Player>(playersBox);
    await Hive.openBox<Challenge>(challengesBox);
    await Hive.openBox<GameRound>(gameRoundsBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox<PlayerGroup>(groupsBox);
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
    // Sync to Firebase
    await FirebaseService.syncPlayer(player);
  }

  static Future<void> updatePlayer(Player player) async {
    await getPlayersBox().put(player.id, player);
    // Sync to Firebase
    await FirebaseService.syncPlayer(player);
  }

  static Future<void> deletePlayer(String id) async {
    await getPlayersBox().delete(id);
    // Delete from Firebase
    await FirebaseService.deletePlayer(id);
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

  static List<Challenge> getChallengesByType(String type) {
    return getAllChallenges()
        .where((challenge) => challenge.type == type)
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
    // Sync to Firebase
    await FirebaseService.syncGameRound(round);
  }

  static Future<void> updateGameRound(GameRound round) async {
    await getGameRoundsBox().put(round.id, round);
    // Sync to Firebase
    await FirebaseService.syncGameRound(round);
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
    await getGroupsBox().clear();
  }

  // Group operations
  static Box<PlayerGroup> getGroupsBox() {
    return Hive.box<PlayerGroup>(groupsBox);
  }

  static List<PlayerGroup> getAllGroups() {
    return getGroupsBox().values.toList();
  }

  static Future<void> addGroup(PlayerGroup group) async {
    await getGroupsBox().put(group.id, group);
  }

  static Future<void> updateGroup(PlayerGroup group) async {
    await getGroupsBox().put(group.id, group);
  }

  static Future<void> deleteGroup(String id) async {
    await getGroupsBox().delete(id);
  }

  static PlayerGroup? getGroup(String id) {
    return getGroupsBox().get(id);
  }

  // Sync with Firebase
  static Future<void> syncWithFirebase() async {
    if (!FirebaseService.isAuthenticated) return;

    try {
      await FirebaseService.syncAllData(
        localPlayers: getAllPlayers(),
        localRounds: getAllGameRounds(),
      );
    } catch (e) {
      AppLogger.error('Error during sync', e);
    }
  }
}
