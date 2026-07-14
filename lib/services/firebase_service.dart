import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/player.dart';
import '../models/game_round.dart';
import '../utils/logger.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static String? _userId;

  static FirebaseFirestore get firestore => _firestore!;
  static FirebaseAuth get auth => _auth!;
  static String? get userId => _userId;

  static Future<void> init() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    await _signInAnonymously();
  }

  static Future<void> _signInAnonymously() async {
    try {
      final userCredential = await _auth!.signInAnonymously();
      _userId = userCredential.user?.uid;
      AppLogger.info('Signed in anonymously: $_userId');
    } catch (e) {
      AppLogger.error('Error signing in anonymously', e);
    }
  }

  static bool get isAuthenticated => _userId != null;

  static Future<void> syncPlayer(Player player) async {
    if (!isAuthenticated) return;

    try {
      await _firestore!
          .collection('users')
          .doc(_userId)
          .collection('players')
          .doc(player.id)
          .set(player.toMap());
    } catch (e) {
      AppLogger.error('Error syncing player', e);
    }
  }

  static Future<void> deletePlayer(String playerId) async {
    if (!isAuthenticated) return;

    try {
      await _firestore!
          .collection('users')
          .doc(_userId)
          .collection('players')
          .doc(playerId)
          .delete();
    } catch (e) {
      AppLogger.error('Error deleting player from Firebase', e);
    }
  }

  static Future<List<Player>> getPlayers() async {
    if (!isAuthenticated) return [];

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(_userId)
          .collection('players')
          .get();

      return snapshot.docs.map((doc) => Player.fromMap(doc.data())).toList();
    } catch (e) {
      AppLogger.error('Error getting players from Firebase', e);
      return [];
    }
  }

  static Stream<List<Player>> playersStream() {
    if (!isAuthenticated) {
      return const Stream.empty();
    }

    return _firestore!
        .collection('users')
        .doc(_userId)
        .collection('players')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Player.fromMap(doc.data())).toList());
  }

  static Future<void> syncGameRound(GameRound round) async {
    if (!isAuthenticated) return;

    try {
      await _firestore!
          .collection('users')
          .doc(_userId)
          .collection('game_rounds')
          .doc(round.id)
          .set(round.toMap());
    } catch (e) {
      AppLogger.error('Error syncing game round', e);
    }
  }

  static Future<List<GameRound>> getGameRounds() async {
    if (!isAuthenticated) return [];

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(_userId)
          .collection('game_rounds')
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GameRound.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting game rounds from Firebase', e);
      return [];
    }
  }

  static Future<void> syncAllData({
    required List<Player> localPlayers,
    required List<GameRound> localRounds,
  }) async {
    if (!isAuthenticated) return;

    try {
      final remotePlayers = await getPlayers();
      final remotePlayerIds = remotePlayers.map((p) => p.id).toSet();

      for (final player in localPlayers) {
        if (!remotePlayerIds.contains(player.id)) {
          await syncPlayer(player);
        }
      }

      for (final round in localRounds) {
        await syncGameRound(round);
      }
    } catch (e) {
      AppLogger.error('Error during full sync', e);
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth?.signOut();
      _userId = null;
    } catch (e) {
      AppLogger.error('Error signing out', e);
    }
  }
}
