class AppConstants {
  // App info
  static const String appName = 'Botabaixo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Jogo de bebida open-source inspirado no Picolo!';

  // Colors (hex)
  static const String primaryColor = '#6A1B9A'; // Deep Purple
  static const String secondaryColor = '#FF6D00'; // Vibrant Orange
  static const String accentColor = '#00BFA5'; // Teal
  static const String backgroundColor = '#121212'; // Dark Grey
  static const String surfaceColor = '#1E1E1E'; // Card Grey

  // Challenge categories
  static const String categoryBebida = 'bebida';
  static const String categoryVerdade = 'verdade';
  static const String categoryCoragem = 'coragem';
  static const String categoryGrupo = 'grupo';

  // Difficulty levels
  static const String difficultyFacil = 'facil';
  static const String difficultyMedio = 'medio';
  static const String difficultyDificil = 'dificil';
  static const String difficultyExtremo = 'extremo';

  // Pronouns
  static const List<String> pronounsPT = ['ele', 'ela', 'elu'];
  static const List<String> pronounsEN = ['he', 'she', 'they'];

  // Pronoun display names
  static const Map<String, String> pronounNamesPT = {
    'ele': 'Ele',
    'ela': 'Ela',
    'elu': 'Elu',
  };

  static const Map<String, String> pronounNamesEN = {
    'he': 'He/Him',
    'she': 'She/Her',
    'they': 'They/Them',
  };

  // Shot colors
  static const Map<String, String> shotColors = {
    'facil': '#4CAF50', // Green
    'medio': '#FF9800', // Orange
    'dificil': '#F44336', // Red
    'extremo': '#9C27B0', // Purple
  };

  // Category icons
  static const Map<String, String> categoryIcons = {
    'bebida': '🍺',
    'verdade': '💬',
    'coragem': '💪',
    'grupo': '👥',
  };

  // Category names
  static const Map<String, String> categoryNamesPT = {
    'bebida': 'Bebida',
    'verdade': 'Verdade',
    'coragem': 'Coragem',
    'grupo': 'Grupo',
  };

  static const Map<String, String> categoryNamesEN = {
    'bebida': 'Drink',
    'verdade': 'Truth',
    'coragem': 'Courage',
    'grupo': 'Group',
  };
}
