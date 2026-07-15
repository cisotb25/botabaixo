import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/group_provider.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import 'players_screen.dart';
import 'groups_screen.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Spacer(),
              const Text(
                '🎮',
                style: TextStyle(fontSize: 80),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Botabaixo',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Jogo de bebida open-source',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // Start Game Button
              Consumer<PlayerProvider>(
                builder: (context, playerProvider, child) {
                  final hasPlayers = playerProvider.players.isNotEmpty;

                  return ElevatedButton.icon(
                    onPressed: hasPlayers
                        ? () => _startGame(context, playerProvider)
                        : () => _showNoPlayersDialog(context),
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: Text(
                      hasPlayers ? 'Iniciar Jogo' : 'Adicione Jogadores',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPlayers
                          ? const Color(0xFF6A1B9A)
                          : Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Manage Players Button
              OutlinedButton.icon(
                onPressed: () => _navigateToPlayers(context),
                icon: const Icon(Icons.people, size: 24),
                label: const Text(
                  'Gerenciar Jogadores',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00BFA5),
                  side: const BorderSide(color: Color(0xFF00BFA5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manage Groups Button
              OutlinedButton.icon(
                onPressed: () => _navigateToGroups(context),
                icon: const Icon(Icons.group, size: 24),
                label: const Text(
                  'Gerenciar Grupos',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6D00),
                  side: const BorderSide(color: Color(0xFFFF6D00)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Player Count
              Consumer<PlayerProvider>(
                builder: (context, playerProvider, child) {
                  return Text(
                    '${playerProvider.players.length} jogador(es) cadastrado(s)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPlayers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayersScreen()),
    );
  }

  void _navigateToGroups(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsScreen()),
    );
  }

  void _startGame(BuildContext context, PlayerProvider playerProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GameSetupSheet(
        players: playerProvider.players,
        onGameStarted: (selectedPlayers, gameMode, customTurns) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                players: selectedPlayers,
                gameMode: gameMode,
                customTurns: customTurns,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNoPlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Nenhum jogador'),
        content: const Text(
          'Adicione pelo menos um jogador para comecar a jogar!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPlayers(context);
            },
            child: const Text('Adicionar Jogadores'),
          ),
        ],
      ),
    );
  }
}

class _GameSetupSheet extends StatefulWidget {
  final List<Player> players;
  final Function(List<Player>, GameMode, int) onGameStarted;

  const _GameSetupSheet({
    required this.players,
    required this.onGameStarted,
  });

  @override
  State<_GameSetupSheet> createState() => _GameSetupSheetState();
}

class _GameSetupSheetState extends State<_GameSetupSheet> {
  final Set<String> _selectedPlayerIds = {};
  GameMode _selectedMode = GameMode.normal;
  int _customTurns = 4;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.7,
      maxChildSize: 0.95,
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
                'Configurar Jogo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            // Game Mode Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo de Jogo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quick mode
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildModeButton('Rapido', '2x', GameMode.quick),
                        ),
                      ),
                      // Normal mode
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildModeButton('Normal', '4x', GameMode.normal),
                        ),
                      ),
                      // Long mode
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildModeButton('Longo', '6x', GameMode.long),
                        ),
                      ),
                      // Custom mode
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildModeButton('Custom', '$_customTurns x', GameMode.custom),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Custom turns slider
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedMode == GameMode.custom
                              ? 'Customizado: $_customTurns desafios por jogador'
                              : GameModeConfig.getConfig(_selectedMode).description,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                      if (_selectedMode == GameMode.custom)
                        Text(
                          '$_customTurns',
                          style: const TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  if (_selectedMode == GameMode.custom)
                    Slider(
                      value: _customTurns.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: const Color(0xFF6A1B9A),
                      onChanged: (value) {
                        setState(() {
                          _customTurns = value.round();
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Groups section
            Consumer<GroupProvider>(
              builder: (context, groupProvider, child) {
                if (groupProvider.groups.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.group, size: 18),
                          label: Text(group.name),
                          backgroundColor:
                              const Color(0xFFFF6D00).withValues(alpha: 0.2),
                          labelStyle:
                              const TextStyle(color: Color(0xFFFF6D00)),
                          side: const BorderSide(color: Color(0xFFFF6D00)),
                          onPressed: () {
                            setState(() {
                              final allSelected = group.playerIds.every(
                                  (id) => _selectedPlayerIds.contains(id));
                              if (allSelected) {
                                for (final id in group.playerIds) {
                                  _selectedPlayerIds.remove(id);
                                }
                              } else {
                                for (final id in group.playerIds) {
                                  _selectedPlayerIds.add(id);
                                }
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Select All button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_selectedPlayerIds.length == widget.players.length) {
                      _selectedPlayerIds.clear();
                    } else {
                      _selectedPlayerIds.addAll(widget.players.map((p) => p.id));
                    }
                  });
                },
                icon: Icon(
                  _selectedPlayerIds.length == widget.players.length
                      ? Icons.deselect
                      : Icons.select_all,
                  size: 20,
                ),
                label: Text(
                  _selectedPlayerIds.length == widget.players.length
                      ? 'Desmarcar Todos'
                      : 'Selecionar Todos',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6D00),
                  side: const BorderSide(color: Color(0xFFFF6D00)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Player list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];
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
                          ? const Color(0xFF6A1B9A)
                          : Colors.grey[800],
                      child: Text(
                        player.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    activeColor: const Color(0xFF6A1B9A),
                  );
                },
              ),
            ),

            // Start button
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: ElevatedButton(
                onPressed: _selectedPlayerIds.isNotEmpty
                    ? () {
                        final selectedPlayers = widget.players
                            .where(
                                (p) => _selectedPlayerIds.contains(p.id))
                            .toList();
                        widget.onGameStarted(selectedPlayers, _selectedMode, _customTurns);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPlayerIds.isNotEmpty
                      ? const Color(0xFF6A1B9A)
                      : Colors.grey[800],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Iniciar com ${_selectedPlayerIds.length} jogador(es)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeButton(String label, String sublabel, GameMode mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[600]!,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
