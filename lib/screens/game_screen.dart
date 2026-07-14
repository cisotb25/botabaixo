import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/game_round.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;

  const GameScreen({super.key, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startNewRound(widget.players);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Desafio'),
        actions: [
          IconButton(
            onPressed: () => _showEndRoundDialog(context),
            icon: const Icon(Icons.stop),
            tooltip: 'Encerrar rodada',
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading &&
              gameProvider.currentRound == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (gameProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    gameProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          final currentRound = gameProvider.currentRound;
          if (currentRound == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentChallenge = gameProvider.getCurrentChallenge();
          final isRoundFinished =
              gameProvider.currentChallengeIndex >= currentRound.challenges.length;

          if (isRoundFinished) {
            return _buildRoundFinished(context, currentRound, gameProvider);
          }

          if (currentChallenge == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildChallengeView(context, currentChallenge, gameProvider);
        },
      ),
    );
  }

  Widget _buildChallengeView(
    BuildContext context,
    RoundChallenge currentChallenge,
    GameProvider gameProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: gameProvider.currentChallengeIndex /
                gameProvider.currentRound!.challenges.length,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 8),
          Text(
            'Desafio ${gameProvider.currentChallengeIndex + 1} de ${gameProvider.currentRound!.challenges.length}',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),

          // Player name
          Text(
            currentChallenge.assignedPlayer.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Pronoun
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentChallenge.assignedPlayer.pronounPT,
              style: const TextStyle(
                color: Color(0xFF6A1B9A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Challenge card
          Expanded(
            child: Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category icon
                    Text(
                      currentChallenge.challenge.getCategoryIcon(),
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),

                    // Category name
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentChallenge.challenge.getCategoryNamePT(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Challenge text
                    Text(
                      currentChallenge.challenge.textPT,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Shots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        currentChallenge.challenge.shots,
                        (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.local_bar,
                            color: Color(0xFFFF6D00),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentChallenge.challenge.shots} shot(s)',
                      style: const TextStyle(
                        color: Color(0xFFFF6D00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Skip button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => gameProvider.skipCurrentChallenge(),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Pular'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Complete button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => gameProvider.completeCurrentChallenge(),
                  icon: const Icon(Icons.check),
                  label: const Text('Feito!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundFinished(
    BuildContext context,
    GameRound currentRound,
    GameProvider gameProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 80,
            color: Color(0xFFFF6D00),
          ),
          const SizedBox(height: 24),
          Text(
            'Rodada Encerrada!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _StatRow(
                    label: 'Total de desafios',
                    value: '${currentRound.challenges.length}',
                  ),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: 'Total de shots',
                    value: '${currentRound.totalShots}',
                    valueColor: const Color(0xFFFF6D00),
                  ),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: 'Jogadores',
                    value: '${currentRound.players.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Back button
          ElevatedButton.icon(
            onPressed: () {
              gameProvider.endRound();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
            label: const Text('Voltar ao Início'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  void _showEndRoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Encerrar Rodada'),
        content: const Text('Tem certeza que deseja encerrar esta rodada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().endRound();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400]),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
