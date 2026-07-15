import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/game_round.dart';
import '../models/game_mode.dart';
import '../services/storage_service.dart';
import '../services/challenge_service.dart';

class GameProvider extends ChangeNotifier {
  GameRound? _currentRound;
  List<GameRound> _gameHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentChallengeIndex = 0;
  GameMode _currentGameMode = GameMode.normal;
  List<ActiveVirus> _activeViruses = [];

  static final Player everyonePlayer = Player(
    id: 'everyone',
    name: 'Todos',
    pronoun: 'they',
  );

  GameRound? get currentRound => _currentRound;
  List<GameRound> get gameHistory => _gameHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentChallengeIndex => _currentChallengeIndex;
  GameMode get currentGameMode => _currentGameMode;
  List<ActiveVirus> get activeViruses => _activeViruses;

  GameProvider() {
    loadGameHistory();
  }

  Future<void> loadGameHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gameHistory = StorageService.getAllGameRounds();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar historico: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startNewRound(List<Player> players, {GameMode mode = GameMode.normal, int customTurns = 4}) async {
    _isLoading = true;
    _error = null;
    _currentGameMode = mode;
    _activeViruses = [];
    notifyListeners();

    try {
      if (players.isEmpty) {
        throw Exception('Selecione pelo menos um jogador');
      }

      if (ChallengeService.challenges.isEmpty) {
        await ChallengeService.loadChallenges();
      }

      final config = mode == GameMode.custom
          ? GameModeConfig.getCustomConfig(customTurns)
          : GameModeConfig.getConfig(mode);
      final totalChallenges = config.getTotalChallenges(players.length);

      // Generate a shuffled deck of challenges (virus_end cards are NOT included)
      final deck = ChallengeService.generateDeck(totalChallenges);

      // Shuffle players for random order
      final shuffledPlayers = List<Player>.from(players)..shuffle(Random());

      // Assign challenges to players
      final roundChallenges = <RoundChallenge>[];
      for (int i = 0; i < deck.length; i++) {
        final challenge = deck[i];
        Player player;

        // Assign group challenges to Everyone player
        if (challenge.isGroupChallenge) {
          player = everyonePlayer;
        } else {
          player = shuffledPlayers[i % shuffledPlayers.length];
        }

        roundChallenges.add(RoundChallenge(
          challenge: challenge,
          assignedPlayer: player,
        ));
      }

      _currentRound = GameRound(
        id: const Uuid().v4(),
        players: players,
        challenges: roundChallenges,
      );

      await StorageService.addGameRound(_currentRound!);
      _currentChallengeIndex = 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao iniciar rodada: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  RoundChallenge? getCurrentChallenge() {
    if (_currentRound == null ||
        _currentChallengeIndex >= _currentRound!.challenges.length) {
      return null;
    }
    return _currentRound!.challenges[_currentChallengeIndex];
  }

  Future<void> completeCurrentChallenge() async {
    if (_currentRound == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentChallenge = getCurrentChallenge();
      if (currentChallenge != null) {
        currentChallenge.complete();

        // Handle virus start cards
        if (currentChallenge.challenge.isVirusStart) {
          final text = currentChallenge.challenge.textPT;
          final playerName = currentChallenge.assignedPlayer.name;
          final randomDuration = 5 + Random().nextInt(11); // 5 to 15
          _activeViruses.add(ActiveVirus(
            id: const Uuid().v4(),
            text: text.replaceAll('{player}', playerName),
            assignedPlayer: currentChallenge.assignedPlayer,
            duration: randomDuration,
            roundsRemaining: randomDuration,
          ));
        }

        // Decrement all active virus counters
        final expiredIds = <String>[];
        for (final virus in _activeViruses) {
          virus.roundsRemaining--;
          if (virus.roundsRemaining <= 0) {
            expiredIds.add(virus.id);
          }
        }
        _activeViruses.removeWhere((v) => expiredIds.contains(v.id));

        _currentChallengeIndex++;

        if (_currentChallengeIndex >= _currentRound!.challenges.length) {
          _currentRound!.endedAt = DateTime.now();
          _currentRound!.isActive = false;
          _gameHistory.add(_currentRound!);
        }

        await StorageService.updateGameRound(_currentRound!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao completar desafio: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> skipCurrentChallenge() async {
    if (_currentRound == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentChallengeIndex++;

      if (_currentChallengeIndex >= _currentRound!.challenges.length) {
        _currentRound!.endedAt = DateTime.now();
        _currentRound!.isActive = false;
        _gameHistory.add(_currentRound!);
      }

      await StorageService.updateGameRound(_currentRound!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao pular desafio: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void endRound() {
    if (_currentRound == null) return;

    _currentRound!.endedAt = DateTime.now();
    _currentRound!.isActive = false;
    _gameHistory.add(_currentRound!);
    _currentRound = null;
    _currentChallengeIndex = 0;
    _activeViruses = [];
    notifyListeners();
  }

  int getTotalSipsInRound() {
    if (_currentRound == null) return 0;
    return _currentRound!.totalSips;
  }

  int getCompletedChallengesCount() {
    if (_currentRound == null) return 0;
    return _currentRound!.completedChallenges;
  }

  int getRemainingChallengesCount() {
    if (_currentRound == null) return 0;
    return _currentRound!.challenges.length - _currentChallengeIndex;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
