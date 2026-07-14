import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/game_round.dart';
import '../services/storage_service.dart';
import '../services/challenge_service.dart';

class GameProvider extends ChangeNotifier {
  GameRound? _currentRound;
  List<GameRound> _gameHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentChallengeIndex = 0;

  GameRound? get currentRound => _currentRound;
  List<GameRound> get gameHistory => _gameHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentChallengeIndex => _currentChallengeIndex;

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
      _error = 'Erro ao carregar histórico: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startNewRound(List<Player> players) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (players.isEmpty) {
        throw Exception('Selecione pelo menos um jogador');
      }

      // Load challenges if not loaded
      if (ChallengeService.challenges.isEmpty) {
        await ChallengeService.loadChallenges();
      }

      // Generate initial challenges for the round
      final challenges = _generateChallengesForRound(players);

      _currentRound = GameRound(
        id: const Uuid().v4(),
        players: players,
        challenges: challenges,
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

  List<RoundChallenge> _generateChallengesForRound(List<Player> players) {
    final challenges = <RoundChallenge>[];
    final numChallenges = players.length * 2; // 2 challenges per player

    for (int i = 0; i < numChallenges; i++) {
      final player = players[i % players.length];
      final challenge = ChallengeService.getRandomChallenge();

      if (challenge != null) {
        challenges.add(RoundChallenge(
          challenge: challenge,
          assignedPlayer: player,
        ));
      }
    }

    return challenges;
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
        _currentChallengeIndex++;

        // Check if round is finished
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

      // Check if round is finished
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
    notifyListeners();
  }

  int getTotalShotsInRound() {
    if (_currentRound == null) return 0;
    return _currentRound!.totalShots;
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
