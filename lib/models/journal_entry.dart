class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<String> tags;
  final String category;
  final int rating;
  final String? imageUrl;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.tags = const [],
    this.category = 'General',
    this.rating = 0,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'tags': tags,
      'category': category,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      title: json['title'] ?? 'Untitled', // Handle older entries without title
      content: json['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      tags: List<String>.from(json['tags']),
      category: json['category'] ?? 'General',
      rating: json['rating'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  // Create new journal entry
  factory JournalEntry.create(
    String title,
    String content,
    List<String> tags,
    String category,
    int rating,
    String? imageUrl,
  ) {
    return JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      timestamp: DateTime.now(),
      tags: tags,
      category: category,
      rating: rating,
      imageUrl: imageUrl,
    );
  }

  // Format time
  String getFormattedTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (entryDate == today) {
      final hour = timestamp.hour == 0
          ? 12
          : (timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour);
      final period = timestamp.hour < 12 ? 'AM' : 'PM';
      return '$hour:${timestamp.minute.toString().padLeft(2, '0')} $period';
    } else if (today.difference(entryDate).inDays == 1) {
      return 'Yesterday';
    } else {
      // Get month name
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[timestamp.month - 1];
      return '$month ${timestamp.day}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry &&
        other.id == id &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.tags.length == tags.length;
  }

  @override
  int get hashCode => Object.hash(id, content, timestamp, tags);
}
