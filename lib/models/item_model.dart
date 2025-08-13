class Item {
  final String name;
  final String location; // 卧室/客厅/厨房/衣帽间/其他
  final String subLocation; // Specific location description (e.g., "抽屉")
  final DateTime addedDate;
  final String icon; // Icon representation

  Item({
    required this.name,
    required this.location,
    required this.subLocation,
    required this.addedDate,
    required this.icon,
  });

  // Factory constructor to create from SharedPreferences data
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] as String,
      location: json['location'] as String,
      subLocation: json['subLocation'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
      icon: json['icon'] as String,
    );
  }

  // Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'subLocation': subLocation,
      'addedDate': addedDate.toIso8601String(),
      'icon': icon,
    };
  }

  // Helper methods for filtering and searching
  static List<Item> searchItems(List<Item> items, String query) {
    if (query.isEmpty) {
      return items;
    }

    final lowerCaseQuery = query.toLowerCase();

    return items
        .where(
          (item) =>
              item.name.toLowerCase().contains(lowerCaseQuery) ||
              item.location.toLowerCase().contains(lowerCaseQuery) ||
              item.subLocation.toLowerCase().contains(lowerCaseQuery),
        )
        .toList();
  }

  // Get distribution by location
  static Map<String, int> getLocationDistribution(List<Item> items) {
    final Map<String, int> distribution = {
      '卧室': 0,
      '客厅': 0,
      '厨房': 0,
      '衣帽间': 0,
      '其他': 0,
    };

    for (var item in items) {
      distribution[item.location] = (distribution[item.location] ?? 0) + 1;
    }

    return distribution;
  }

  // Calculate percentage for each location
  static Map<String, double> getLocationPercentages(List<Item> items) {
    final Map<String, int> distribution = getLocationDistribution(items);
    final int totalItems = items.length;

    if (totalItems == 0) {
      return {'卧室': 0, '客厅': 0, '厨房': 0, '衣帽间': 0, '其他': 0};
    }

    final Map<String, double> percentages = {};

    distribution.forEach((location, count) {
      percentages[location] = (count / totalItems) * 100;
    });

    return percentages;
  }

  // Get recently added items
  static List<Item> getRecentlyAdded(List<Item> items, {int limit = 5}) {
    final sortedItems = List<Item>.from(items)
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));

    return sortedItems.take(limit).toList();
  }
}
