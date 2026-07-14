import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../providers/player_provider.dart';
import '../models/player_group.dart';
import '../models/player.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        actions: [
          IconButton(
            onPressed: () => _showAddGroupDialog(context),
            icon: const Icon(Icons.group_add),
            tooltip: 'Adicionar grupo',
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    groupProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: groupProvider.loadGroups,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (groupProvider.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum grupo criado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie grupos para organizar seus jogadores!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddGroupDialog(context),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Criar Grupo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];
              return _GroupCard(
                group: group,
                onEdit: () => _showEditGroupDialog(context, group),
                onDelete: () => _showDeleteConfirmation(context, group),
                onManagePlayers: () => _showManagePlayersDialog(context, group),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroupDialog(context),
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Criar Grupo'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nome do Grupo',
            hintText: 'Ex: Amigos da faculdade',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<GroupProvider>().addGroup(
                      nameController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, PlayerGroup group) {
    final nameController = TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Editar Grupo'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Nome do Grupo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<GroupProvider>().updateGroup(
                      group.id,
                      nameController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PlayerGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Deletar Grupo'),
        content: Text('Tem certeza que deseja deletar o grupo "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GroupProvider>().deleteGroup(group.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _showManagePlayersDialog(BuildContext context, PlayerGroup group) {
    final playerProvider = context.read<PlayerProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ManagePlayersSheet(
        group: group,
        allPlayers: playerProvider.players,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final PlayerGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManagePlayers;

  const _GroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onManagePlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00BFA5),
          radius: 24,
          child: Text(
            group.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '${group.playerIds.length} jogador(es)',
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            } else if (value == 'manage') {
              onManagePlayers();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'manage',
              child: Row(
                children: [
                  Icon(Icons.people, size: 20),
                  SizedBox(width: 8),
                  Text('Gerenciar Jogadores'),
                ],
              ),
            ),
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

class _ManagePlayersSheet extends StatefulWidget {
  final PlayerGroup group;
  final List<Player> allPlayers;

  const _ManagePlayersSheet({
    required this.group,
    required this.allPlayers,
  });

  @override
  State<_ManagePlayersSheet> createState() => _ManagePlayersSheetState();
}

class _ManagePlayersSheetState extends State<_ManagePlayersSheet> {
  late Set<String> _selectedPlayerIds;

  @override
  void initState() {
    super.initState();
    _selectedPlayerIds = Set<String>.from(widget.group.playerIds);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gerenciar Jogadores - ${widget.group.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // Player list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.allPlayers.length,
                itemBuilder: (context, index) {
                  final player = widget.allPlayers[index];
                  final isSelected = _selectedPlayerIds.contains(player.id);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPlayerIds.add(player.id);
                        } else {
                          _selectedPlayerIds.remove(player.id);
                        }
                      });
                    },
                    title: Text(player.name),
                    subtitle: Text(player.pronounPT),
                    secondary: CircleAvatar(
                      backgroundColor: isSelected
                          ? const Color(0xFF00BFA5)
                          : Colors.grey[800],
                      child: Text(
                        player.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    activeColor: const Color(0xFF00BFA5),
                  );
                },
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final groupProvider = context.read<GroupProvider>();

                  // Remove players not selected
                  for (final playerId in widget.group.playerIds) {
                    if (!_selectedPlayerIds.contains(playerId)) {
                      groupProvider.removePlayerFromGroup(
                          widget.group.id, playerId);
                    }
                  }

                  // Add newly selected players
                  for (final playerId in _selectedPlayerIds) {
                    if (!widget.group.playerIds.contains(playerId)) {
                      groupProvider.addPlayerToGroup(
                          widget.group.id, playerId);
                    }
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar Alteracoes'),
              ),
            ),
          ],
        );
      },
    );
  }
}
