class Criterion {
  final String id;
  final String name;
  final double weight;
  final String icon;

  Criterion({
    required this.id,
    required this.name,
    required this.weight,
    this.icon = 'circle',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'icon': icon,
    };
  }

  factory Criterion.fromJson(Map<String, dynamic> json) {
    return Criterion(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      icon: json['icon'] as String? ?? 'circle',
    );
  }

  Criterion copyWith({
    String? id,
    String? name,
    double? weight,
    String? icon,
  }) {
    return Criterion(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Criterion &&
        other.id == id &&
        other.name == name &&
        other.weight == weight &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ weight.hashCode ^ icon.hashCode;
  }

  @override
  String toString() {
    return 'Criterion(id: $id, name: $name, weight: $weight, icon: $icon)';
  }
}