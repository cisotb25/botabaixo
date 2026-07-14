import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/player.dart';
import '../utils/constants.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
        actions: [
          IconButton(
            onPressed: () => _showAddPlayerDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'Adicionar jogador',
          ),
        ],
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          if (playerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (playerProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    playerProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: playerProvider.loadPlayers,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (playerProvider.players.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum jogador cadastrado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione jogadores para começar a jogar!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPlayerDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Adicionar Jogador'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: playerProvider.players.length,
            itemBuilder: (context, index) {
              final player = playerProvider.players[index];
              return _PlayerCard(
                player: player,
                onEdit: () => _showEditPlayerDialog(context, player),
                onDelete: () => _showDeleteConfirmation(context, player),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayerDialog(context),
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedPronoun = AppConstants.pronounsPT[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Adicionar Jogador'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Digite o nome do jogador',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedPronoun,
                  decoration: InputDecoration(
                    labelText: 'Pronome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                  items: AppConstants.pronounsPT.map((pronoun) {
                    return DropdownMenuItem(
                      value: pronoun,
                      child: Text(AppConstants.pronounNamesPT[pronoun]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPronoun = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    context.read<PlayerProvider>().addPlayer(
                          nameController.text.trim(),
                          selectedPronoun,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditPlayerDialog(BuildContext context, Player player) {
    final nameController = TextEditingController(text: player.name);
    String selectedPronoun = player.pronoun;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Editar Jogador'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Digite o nome do jogador',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedPronoun,
                  decoration: InputDecoration(
                    labelText: 'Pronome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                  ),
                  items: AppConstants.pronounsPT.map((pronoun) {
                    return DropdownMenuItem(
                      value: pronoun,
                      child: Text(AppConstants.pronounNamesPT[pronoun]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPronoun = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    context.read<PlayerProvider>().updatePlayer(
                          player.id,
                          nameController.text.trim(),
                          selectedPronoun,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Deletar Jogador'),
        content: Text('Tem certeza que deseja deletar ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<PlayerProvider>().deletePlayer(player.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlayerCard({
    required this.player,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6A1B9A),
          radius: 24,
          child: Text(
            player.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          player.pronounPT,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Deletar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
