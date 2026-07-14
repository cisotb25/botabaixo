import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../services/storage_service.dart';

class PlayerProvider extends ChangeNotifier {
  List<Player> _players = [];
  bool _isLoading = false;
  String? _error;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PlayerProvider() {
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _players = StorageService.getAllPlayers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar jogadores: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPlayer(String name, String pronoun) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final player = Player(
        id: const Uuid().v4(),
        name: name,
        pronoun: pronoun,
      );

      await StorageService.addPlayer(player);
      _players.add(player);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar jogador: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlayer(String id, String name, String pronoun) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final playerIndex = _players.indexWhere((p) => p.id == id);
      if (playerIndex != -1) {
        final updatedPlayer = Player(
          id: id,
          name: name,
          pronoun: pronoun,
          createdAt: _players[playerIndex].createdAt,
        );

        await StorageService.updatePlayer(updatedPlayer);
        _players[playerIndex] = updatedPlayer;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar jogador: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlayer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.deletePlayer(id);
      _players.removeWhere((p) => p.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar jogador: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Player> searchPlayers(String query) {
    if (query.isEmpty) return _players;
    return _players
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
