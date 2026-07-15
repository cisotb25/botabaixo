enum GameMode {
  quick,
  normal,
  long,
  custom,
}

class GameModeConfig {
  final GameMode mode;
  final String name;
  final String description;
  final int turnsPerPlayer;

  const GameModeConfig({
    required this.mode,
    required this.name,
    required this.description,
    required this.turnsPerPlayer,
  });

  int getTotalChallenges(int playerCount) {
    return turnsPerPlayer * playerCount;
  }

  static const Map<GameMode, GameModeConfig> configs = {
    GameMode.quick: GameModeConfig(
      mode: GameMode.quick,
      name: 'Rapido',
      description: '2 desafios por jogador',
      turnsPerPlayer: 2,
    ),
    GameMode.normal: GameModeConfig(
      mode: GameMode.normal,
      name: 'Normal',
      description: '4 desafios por jogador',
      turnsPerPlayer: 4,
    ),
    GameMode.long: GameModeConfig(
      mode: GameMode.long,
      name: 'Longo',
      description: '6 desafios por jogador',
      turnsPerPlayer: 6,
    ),
  };

  static GameModeConfig getConfig(GameMode mode) {
    return configs[mode]!;
  }

  static List<GameModeConfig> get allModes => configs.values.toList();

  static GameModeConfig getCustomConfig(int turnsPerPlayer) {
    return GameModeConfig(
      mode: GameMode.custom,
      name: 'Customizado',
      description: '$turnsPerPlayer desafios por jogador',
      turnsPerPlayer: turnsPerPlayer,
    );
  }
}
