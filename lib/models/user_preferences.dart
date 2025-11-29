class UserPreferences {
  final List<String> favoriteCategories;
  final bool breakingNewsEnabled;
  final bool notificationsEnabled;
  final String language;

  UserPreferences({
    this.favoriteCategories = const ['general'],
    this.breakingNewsEnabled = true,
    this.notificationsEnabled = true,
    this.language = 'vi',
  });

  /// Create UserPreferences from Firestore data
  factory UserPreferences.fromFirestore(Map<String, dynamic> data) {
    return UserPreferences(
      favoriteCategories: List<String>.from(data['favoriteCategories'] ?? ['general']),
      breakingNewsEnabled: data['breakingNewsEnabled'] ?? true,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      language: data['language'] ?? 'vi',
    );
  }

  /// Convert UserPreferences to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'favoriteCategories': favoriteCategories,
      'breakingNewsEnabled': breakingNewsEnabled,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
    };
  }

  /// Create a copy of UserPreferences with updated fields
  UserPreferences copyWith({
    List<String>? favoriteCategories,
    bool? breakingNewsEnabled,
    bool? notificationsEnabled,
    String? language,
  }) {
    return UserPreferences(
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      breakingNewsEnabled: breakingNewsEnabled ?? this.breakingNewsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}