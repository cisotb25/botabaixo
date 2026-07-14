import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/player_group.dart';
import '../services/storage_service.dart';

class GroupProvider extends ChangeNotifier {
  List<PlayerGroup> _groups = [];
  bool _isLoading = false;
  String? _error;

  List<PlayerGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GroupProvider() {
    loadGroups();
  }

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = StorageService.getAllGroups();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar grupos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGroup(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final group = PlayerGroup(
        id: const Uuid().v4(),
        name: name,
      );

      await StorageService.addGroup(group);
      _groups.add(group);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar grupo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGroup(String id, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final groupIndex = _groups.indexWhere((g) => g.id == id);
      if (groupIndex != -1) {
        final updatedGroup = PlayerGroup(
          id: id,
          name: name,
          playerIds: _groups[groupIndex].playerIds,
          createdAt: _groups[groupIndex].createdAt,
        );

        await StorageService.updateGroup(updatedGroup);
        _groups[groupIndex] = updatedGroup;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar grupo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.deleteGroup(id);
      _groups.removeWhere((g) => g.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar grupo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPlayerToGroup(String groupId, String playerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        group.addPlayer(playerId);
        await StorageService.updateGroup(group);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar jogador ao grupo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePlayerFromGroup(String groupId, String playerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        group.removePlayer(playerId);
        await StorageService.updateGroup(group);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao remover jogador do grupo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  PlayerGroup? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
