import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/game_round.dart';
import '../models/game_mode.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final GameMode gameMode;
  final int customTurns;

  const GameScreen({
    super.key,
    required this.players,
    this.gameMode = GameMode.normal,
    this.customTurns = 4,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<GameProvider>()
          .startNewRound(widget.players, mode: widget.gameMode, customTurns: widget.customTurns);
    });
  }

  void _onTap(GameProvider gameProvider) {
    HapticFeedback.lightImpact();
    gameProvider.completeCurrentChallenge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botabaixo'),
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
          if (gameProvider.isLoading && gameProvider.currentRound == null) {
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
          final isRoundFinished = gameProvider.currentChallengeIndex >=
              currentRound.challenges.length;

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
    final challenge = currentChallenge.challenge;
    final typeColor = Color(challenge.colorValue);

    return GestureDetector(
      onTap: () => _onTap(gameProvider),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: gameProvider.currentChallengeIndex /
                  gameProvider.currentRound!.challenges.length,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(typeColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Desafio ${gameProvider.currentChallengeIndex + 1} de ${gameProvider.currentRound!.challenges.length}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),

            // Active viruses banner
            if (gameProvider.activeViruses.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF9C27B0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🦠', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Virus Ativo${gameProvider.activeViruses.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF9C27B0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...gameProvider.activeViruses.map((virus) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        virus.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    )),
                  ],
                ),
              ),

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

            // Pronoun tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentChallenge.assignedPlayer.pronounPT,
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Challenge card
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Type icon
                      Text(
                        challenge.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),

                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          challenge.typeNamePT,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Challenge text
                      Text(
                        challenge.getText(
                          currentChallenge.assignedPlayer.name,
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Sips indicator
                      if (challenge.sips > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_bar,
                              color: typeColor,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${challenge.sips} gole(s)',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                      // Give sips indicator
                      if (challenge.giveSips)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.redeem,
                              color: Color(0xFF00BFA5),
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'De ${challenge.giveSipsAmount} gole(s) para alguem',
                              style: const TextStyle(
                                color: Color(0xFF00BFA5),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                      // Virus type - show special label
                      if (challenge.isVirus)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Este efeito continua ate ser cancelado!',
                            style: TextStyle(
                              color: Color(0xFF9C27B0),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      // Bottoms Up - show special label
                      if (challenge.isBottomsUp)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Drink it all! Sem desculpas!',
                            style: TextStyle(
                              color: Color(0xFFF44336),
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tap hint
            Text(
              'Toque em qualquer lugar para continuar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundFinished(
    BuildContext context,
    GameRound currentRound,
    GameProvider gameProvider,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
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
                    label: 'Total de goles',
                    value: '${currentRound.totalSips}',
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
            label: const Text('Voltar ao Inicio'),
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
