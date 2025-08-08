class UserProfile {
  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isDarkMode;
  final bool enableNotifications;

  UserProfile({
    required this.name,
    this.email,
    this.avatarUrl,
    this.isDarkMode = true,
    this.enableNotifications = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isDarkMode': isDarkMode,
      'enableNotifications': enableNotifications,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'User',
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      isDarkMode: json['isDarkMode'] ?? true,
      enableNotifications: json['enableNotifications'] ?? true,
    );
  }

  // Default user profile
  factory UserProfile.defaultProfile() {
    return UserProfile(
        name: 'User', isDarkMode: true, enableNotifications: true);
  }

  // Update theme mode
  UserProfile copyWithThemeMode(bool isDark) {
    return UserProfile(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isDarkMode: isDark,
      enableNotifications: enableNotifications,
    );
  }

  // Update notification settings
  UserProfile copyWithNotificationSettings(bool enableNotifs) {
    return UserProfile(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isDarkMode: isDarkMode,
      enableNotifications: enableNotifs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.name == name &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        other.isDarkMode == isDarkMode &&
        other.enableNotifications == enableNotifications;
  }

  @override
  int get hashCode =>
      Object.hash(name, email, avatarUrl, isDarkMode, enableNotifications);
}
