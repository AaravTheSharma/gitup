class AppConstants {
  // Colors
  static const int primaryColor = 0xFF2563EB;
  static const int primaryLightColor = 0xFF3B82F6;
  static const int primaryDarkColor = 0xFF1D4ED8;
  static const int secondaryColor = 0xFF10B981;
  static const int dangerColor = 0xFFEF4444;
  static const int backgroundColor = 0xFFF8FAFC;
  static const int surfaceColor = 0xFFFFFFFF;
  static const int textPrimaryColor = 0xFF1E293B;
  static const int textSecondaryColor = 0xFF64748B;

  // Dark theme colors
  static const int darkBackgroundColor = 0xFF1E293B;
  static const int darkSurfaceColor = 0xFF334155;
  static const int darkTextPrimaryColor = 0xFFF1F5F9;
  static const int darkTextSecondaryColor = 0xFF94A3B8;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 40.0;

  // Decision status
  static const String statusInProgress = 'in-progress';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  // Storage keys
  static const String keyDecisions = 'decisions';
  static const String keyThemeMode = 'theme_mode';

  // Default criteria
  static const List<Map<String, dynamic>> defaultCriteria = [
    {'name': 'Salary', 'icon': 'coins'},
    {'name': 'Growth', 'icon': 'chart-line'},
    {'name': 'Happiness', 'icon': 'heart'},
    {'name': 'Work-life', 'icon': 'balance-scale'},
    {'name': 'Culture', 'icon': 'users'},
    {'name': 'Commute', 'icon': 'map-marker-alt'},
    {'name': 'Job Security', 'icon': 'shield-alt'},
    {'name': 'Learning', 'icon': 'graduation-cap'},
  ];

  // Decision templates
  static const List<Map<String, dynamic>> decisionTemplates = [
    {
      'title': 'Career Decision',
      'description': 'Changing jobs, accepting offers, career pivots',
      'icon': 'briefcase',
      'color': 0xFF3B82F6,
      'criteria': ['Salary', 'Growth', 'Work-life', 'Culture', 'Learning'],
    },
    {
      'title': 'Housing Decision',
      'description': 'Buying, renting, moving locations',
      'icon': 'home',
      'color': 0xFF10B981,
      'criteria': ['Cost', 'Location', 'Size', 'Commute', 'Neighborhood'],
    },
    {
      'title': 'Relationship Decision',
      'description': 'Personal choices involving relationships',
      'icon': 'heart',
      'color': 0xFFA855F7,
      'criteria': [
        'Compatibility',
        'Trust',
        'Communication',
        'Future Goals',
        'Happiness',
      ],
    },
    {
      'title': 'Financial Decision',
      'description': 'Major purchases, investments, budgeting',
      'icon': 'dollar-sign',
      'color': 0xFFF59E0B,
      'criteria': ['Cost', 'ROI', 'Risk', 'Liquidity', 'Long-term Value'],
    },
    {
      'title': 'Custom Decision',
      'description': 'Create your own decision from scratch',
      'icon': 'plus-circle',
      'color': 0xFFEF4444,
      'criteria': [],
    },
  ];
}
