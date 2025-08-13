class Cycle {
  final int currentDay;
  final String phase; // 经期/排卵期/安全期/黄体期
  final DateTime nextPeriodDate;
  final DateTime lastPeriodDate;
  final int cycleDuration; // Average cycle duration in days
  final int periodDuration; // Average period duration in days
  final Map<String, List<String>> symptoms; // Symptoms by date
  final Map<String, String> mood; // Mood by date
  final Map<String, String> flow; // Flow intensity by date (for period days)
  final List<String> notes; // General notes

  Cycle({
    required this.currentDay,
    required this.phase,
    required this.nextPeriodDate,
    required this.lastPeriodDate,
    required this.cycleDuration,
    required this.periodDuration,
    this.symptoms = const {},
    this.mood = const {},
    this.flow = const {},
    this.notes = const [],
  });

  // Factory constructor to create from SharedPreferences data
  factory Cycle.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> symptomsMap = {};
    if (json['symptoms'] != null) {
      final Map<String, dynamic> symptomsJson =
          json['symptoms'] as Map<String, dynamic>;
      symptomsJson.forEach((key, value) {
        if (value is List) {
          symptomsMap[key] = List<String>.from(value);
        }
      });
    }

    Map<String, String> moodMap = {};
    if (json['mood'] != null) {
      final Map<String, dynamic> moodJson =
          json['mood'] as Map<String, dynamic>;
      moodJson.forEach((key, value) {
        if (value is String) {
          moodMap[key] = value;
        }
      });
    }

    Map<String, String> flowMap = {};
    if (json['flow'] != null) {
      final Map<String, dynamic> flowJson =
          json['flow'] as Map<String, dynamic>;
      flowJson.forEach((key, value) {
        if (value is String) {
          flowMap[key] = value;
        }
      });
    }

    List<String> notesList = [];
    if (json['notes'] != null) {
      notesList = List<String>.from(json['notes'] as List);
    }

    return Cycle(
      currentDay: json['currentDay'] as int,
      phase: json['phase'] as String,
      nextPeriodDate: DateTime.parse(json['nextPeriodDate'] as String),
      lastPeriodDate: DateTime.parse(json['lastPeriodDate'] as String),
      cycleDuration: json['cycleDuration'] as int,
      periodDuration: json['periodDuration'] as int,
      symptoms: symptomsMap,
      mood: moodMap,
      flow: flowMap,
      notes: notesList,
    );
  }

  // Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'currentDay': currentDay,
      'phase': phase,
      'nextPeriodDate': nextPeriodDate.toIso8601String(),
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'cycleDuration': cycleDuration,
      'periodDuration': periodDuration,
      'symptoms': symptoms,
      'mood': mood,
      'flow': flow,
      'notes': notes,
    };
  }

  // Create a copy with updated values
  Cycle copyWith({
    int? currentDay,
    String? phase,
    DateTime? nextPeriodDate,
    DateTime? lastPeriodDate,
    int? cycleDuration,
    int? periodDuration,
    Map<String, List<String>>? symptoms,
    Map<String, String>? mood,
    Map<String, String>? flow,
    List<String>? notes,
  }) {
    return Cycle(
      currentDay: currentDay ?? this.currentDay,
      phase: phase ?? this.phase,
      nextPeriodDate: nextPeriodDate ?? this.nextPeriodDate,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      cycleDuration: cycleDuration ?? this.cycleDuration,
      periodDuration: periodDuration ?? this.periodDuration,
      symptoms: symptoms ?? Map.from(this.symptoms),
      mood: mood ?? Map.from(this.mood),
      flow: flow ?? Map.from(this.flow),
      notes: notes ?? List.from(this.notes),
    );
  }

  // Calculate the phase based on the current day
  static String calculatePhase(int currentDay, int cycleDuration) {
    if (currentDay <= 7) {
      return 'Menstrual';
    } else if (currentDay >= 11 && currentDay <= 17) {
      return 'Ovulation';
    } else if (currentDay > 17) {
      return 'Safe';
    } else {
      return 'Luteal';
    }
  }

  // Calculate days until next period
  int daysUntilNextPeriod() {
    return nextPeriodDate.difference(DateTime.now()).inDays;
  }

  // Get fertility status description
  String getFertilityStatus() {
    if (phase == 'Ovulation') {
      return 'Ovulation - High fertility';
    } else if (phase == 'Menstrual') {
      return 'Menstrual - Low fertility';
    } else if (phase == 'Safe') {
      return 'Safe - Low fertility';
    } else {
      return 'Luteal - Medium fertility';
    }
  }

  // Add symptom for current date
  Cycle addSymptom(String symptom) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedSymptoms = Map<String, List<String>>.from(symptoms);

    if (updatedSymptoms.containsKey(today)) {
      if (!updatedSymptoms[today]!.contains(symptom)) {
        updatedSymptoms[today] = [...updatedSymptoms[today]!, symptom];
      }
    } else {
      updatedSymptoms[today] = [symptom];
    }

    return copyWith(symptoms: updatedSymptoms);
  }

  // Remove symptom for current date
  Cycle removeSymptom(String symptom) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedSymptoms = Map<String, List<String>>.from(symptoms);

    if (updatedSymptoms.containsKey(today)) {
      updatedSymptoms[today] =
          updatedSymptoms[today]!.where((s) => s != symptom).toList();
      if (updatedSymptoms[today]!.isEmpty) {
        updatedSymptoms.remove(today);
      }
    }

    return copyWith(symptoms: updatedSymptoms);
  }

  // Set mood for current date
  Cycle setMood(String moodValue) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedMood = Map<String, String>.from(mood);
    updatedMood[today] = moodValue;
    return copyWith(mood: updatedMood);
  }

  // Set flow intensity for current date
  Cycle setFlow(String flowIntensity) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedFlow = Map<String, String>.from(flow);
    updatedFlow[today] = flowIntensity;
    return copyWith(flow: updatedFlow); //sadasdasdad
  }

  // Add a note
  Cycle addNote(String note) {
    final updatedNotes = List<String>.from(notes);
    updatedNotes.add(note); //dfsdfsdfsdf
    return copyWith(notes: updatedNotes);
  }

  // Get today's symptoms
  List<String> getTodaySymptoms() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return symptoms[today] ?? [];
  }

  // Get today's mood
  String getTodayMood() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return mood[today] ?? '';
  }

  // Get today's flow
  String getTodayFlow() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return flow[today] ?? '';
  }
}
