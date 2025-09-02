class Option {
  final String id;
  final String name;
  final Map<String, int> scores;

  Option({
    required this.id,
    required this.name,
    Map<String, int>? scores,
  }) : scores = scores ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scores': scores,
    };
  }

  factory Option.fromJson(Map<String, dynamic> json) {
    final scoresMap = json['scores'] as Map<String, dynamic>? ?? {};
    final scores = <String, int>{};
    
    for (final entry in scoresMap.entries) {
      scores[entry.key] = (entry.value as num).toInt();
    }

    return Option(
      id: json['id'] as String,
      name: json['name'] as String,
      scores: scores,
    );
  }

  Option copyWith({
    String? id,
    String? name,
    Map<String, int>? scores,
  }) {
    return Option(
      id: id ?? this.id,
      name: name ?? this.name,
      scores: scores ?? Map<String, int>.from(this.scores),
    );
  }

  void setScore(String criterionId, int score) {
    scores[criterionId] = score;
  }

  int getScore(String criterionId) {
    return scores[criterionId] ?? 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Option &&
        other.id == id &&
        other.name == name &&
        _mapsEqual(other.scores, scores);
  }

  bool _mapsEqual(Map<String, int> map1, Map<String, int> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ scores.hashCode;
  }

  @override
  String toString() {
    return 'Option(id: $id, name: $name, scores: $scores)';
  }
}