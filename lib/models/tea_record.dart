class TeaRecord {
  final String id;
  final String name;
  final String brand;
  final double price;
  final int rating; // 1-5
  final DateTime timestamp;
  final String? notes;
  final String? imagePath;
  final String type; // 奶茶 or 咖啡

  TeaRecord({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.timestamp,
    this.notes,
    this.imagePath,
    this.type = '奶茶',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'rating': rating,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'notes': notes,
      'imagePath': imagePath,
      'type': type,
    };
  }

  factory TeaRecord.fromJson(Map<String, dynamic> json) {
    return TeaRecord(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      price: json['price'],
      rating: json['rating'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      notes: json['notes'],
      imagePath: json['imagePath'],
      type: json['type'] ?? '奶茶',
    );
  }

  // 创建新的记录
  factory TeaRecord.create({
    required String name,
    required String brand,
    required double price,
    required int rating,
    String? notes,
    String? imagePath,
    String type = '奶茶',
  }) {
    return TeaRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      brand: brand,
      price: price,
      rating: rating,
      timestamp: DateTime.now(),
      notes: notes,
      imagePath: imagePath,
      type: type,
    );
  }

  // 格式化时间
  String getFormattedTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final difference = now.difference(timestamp);

    if (difference.inHours < 24 && recordDate == today) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} mins ago';
      } else {
        return '${difference.inHours} hrs ago';
      }
    } else if (today.difference(recordDate).inDays == 1) {
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
    return other is TeaRecord &&
        other.id == id &&
        other.name == name &&
        other.brand == brand &&
        other.price == price &&
        other.rating == rating;
  }

  @override
  int get hashCode => Object.hash(id, name, brand, price, rating);
}
