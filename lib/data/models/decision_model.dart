import 'criterion_model.dart';
import 'option_model.dart';

class Decision {
  final String id;
  final String title;
  final List<Option> options;
  final List<Criterion> criteria;
  final String status;
  final DateTime creationDate;
  final String category;

  Decision({
    required this.id,
    required this.title,
    required this.options,
    required this.criteria,
    required this.status,
    required this.creationDate,
    this.category = 'Custom',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'options': options.map((option) => option.toJson()).toList(),
      'criteria': criteria.map((criterion) => criterion.toJson()).toList(),
      'status': status,
      'creationDate': creationDate.toIso8601String(),
      'category': category,
    };
  }

  factory Decision.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List<dynamic>? ?? [];
    final criteriaList = json['criteria'] as List<dynamic>? ?? [];

    return Decision(
      id: json['id'] as String,
      title: json['title'] as String,
      options: optionsList
          .map((optionJson) => Option.fromJson(optionJson as Map<String, dynamic>))
          .toList(),
      criteria: criteriaList
          .map((criterionJson) => Criterion.fromJson(criterionJson as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      category: json['category'] as String? ?? 'Custom',
    );
  }

  Decision copyWith({
    String? id,
    String? title,
    List<Option>? options,
    List<Criterion>? criteria,
    String? status,
    DateTime? creationDate,
    String? category,
  }) {
    return Decision(
      id: id ?? this.id,
      title: title ?? this.title,
      options: options ?? List<Option>.from(this.options),
      criteria: criteria ?? List<Criterion>.from(this.criteria),
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      category: category ?? this.category,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isArchived => status == 'archived';
  bool get isInProgress => status == 'in-progress';

  double getProgress() {
    if (criteria.isEmpty || options.isEmpty) return 0.0;
    
    int totalScores = 0;
    int completedScores = 0;
    
    for (final option in options) {
      for (final criterion in criteria) {
        totalScores++;
        if (option.getScore(criterion.id) > 0) {
          completedScores++;
        }
      }
    }
    
    return totalScores > 0 ? completedScores / totalScores : 0.0;
  }

  bool get hasAllScores {
    for (final option in options) {
      for (final criterion in criteria) {
        if (option.getScore(criterion.id) == 0) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Decision &&
        other.id == id &&
        other.title == title &&
        _listsEqual(other.options, options) &&
        _listsEqual(other.criteria, criteria) &&
        other.status == status &&
        other.creationDate == creationDate &&
        other.category == category;
  }

  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        options.hashCode ^
        criteria.hashCode ^
        status.hashCode ^
        creationDate.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'Decision(id: $id, title: $title, status: $status, category: $category)';
  }
}