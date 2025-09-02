import '../data/models/decision_model.dart';
import '../data/models/option_model.dart';
import '../data/models/criterion_model.dart';
import '../data/services/ai_service.dart';

class DecisionService {
  static DecisionService? _instance;
  late AIService _aiService;
  
  DecisionService._() {
    _aiService = AIService.getInstance();
  }
  
  static DecisionService getInstance() {
    _instance ??= DecisionService._();
    return _instance!;
  }

  /// Calculate weighted scores for all options in a decision
  Map<String, double> calculateScores(Decision decision) {
    final Map<String, double> scores = {};
    
    if (decision.criteria.isEmpty || decision.options.isEmpty) {
      return scores;
    }

    // Calculate total weight to normalize
    double totalWeight = decision.criteria.fold(0.0, (sum, criterion) => sum + criterion.weight);
    
    if (totalWeight == 0) {
      return scores;
    }

    for (final option in decision.options) {
      double weightedScore = 0.0;
      
      for (final criterion in decision.criteria) {
        final score = option.getScore(criterion.id);
        final normalizedWeight = criterion.weight / totalWeight;
        weightedScore += score * normalizedWeight;
      }
      
      scores[option.id] = weightedScore;
    }
    
    return scores;
  }

  /// Get the best option based on calculated scores
  Option? getBestOption(Decision decision) {
    final scores = calculateScores(decision);
    
    if (scores.isEmpty) return null;
    
    String bestOptionId = '';
    double bestScore = -1;
    
    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestOptionId = entry.key;
      }
    }
    
    return decision.options.firstWhere(
      (option) => option.id == bestOptionId,
      orElse: () => decision.options.first,
    );
  }

  /// Generate analysis report text
  String generateAnalysisReport(Decision decision) {
    final scores = calculateScores(decision);
    final bestOption = getBestOption(decision);
    
    if (scores.isEmpty || bestOption == null) {
      return 'Unable to generate analysis. Please ensure all options are scored.';
    }

    final sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestScore = sortedScores.first.value;
    final secondBestScore = sortedScores.length > 1 ? sortedScores[1].value : 0.0;
    final scoreDifference = bestScore - secondBestScore;

    final strongestCriteria = _getStrongestCriteria(decision, bestOption);
    final weakestCriteria = _getWeakestCriteria(decision, bestOption);

    String analysis = 'Based on your weight assignments, ';
    
    final bestOptionName = decision.options
        .firstWhere((opt) => opt.id == sortedScores.first.key)
        .name;
    
    if (scoreDifference > 1.0) {
      analysis += '$bestOptionName significantly outperforms other options';
    } else if (scoreDifference > 0.5) {
      analysis += '$bestOptionName moderately outperforms other options';
    } else {
      analysis += 'the options are quite close, with $bestOptionName having a slight edge';
    }

    if (strongestCriteria.isNotEmpty) {
      analysis += ', particularly excelling in ${strongestCriteria.join(', ')}';
    }

    if (weakestCriteria.isNotEmpty) {
      analysis += ' but showing weakness in ${weakestCriteria.join(', ')}';
    }

    analysis += '.';

    return analysis;
  }

  /// Generate AI-powered analysis report
  Future<String> generateAIAnalysisReport(Decision decision) async {
    try {
      return await _aiService.generateDecisionAnalysis(decision);
    } catch (e) {
      // Fallback to basic analysis if AI fails
      return generateAnalysisReport(decision);
    }
  }

  /// Get AI suggestions for criteria
  Future<List<String>> getAISuggestedCriteria(String decisionTitle, String category) async {
    try {
      return await _aiService.suggestCriteria(decisionTitle, category);
    } catch (e) {
      // Fallback to default criteria
      return [];
    }
  }

  /// Generate AI insights for decision patterns
  Future<String> generateAIInsights(List<Decision> decisions) async {
    try {
      return await _aiService.generateInsights(decisions);
    } catch (e) {
      return 'Unable to generate AI insights at this time. Please try again later.';
    }
  }

  /// Get criteria where the best option performs strongest
  List<String> _getStrongestCriteria(Decision decision, Option bestOption) {
    final List<String> strongest = [];
    
    for (final criterion in decision.criteria) {
      final bestScore = bestOption.getScore(criterion.id);
      bool isStrongest = true;
      
      for (final option in decision.options) {
        if (option.id != bestOption.id && option.getScore(criterion.id) >= bestScore) {
          isStrongest = false;
          break;
        }
      }
      
      if (isStrongest && bestScore >= 7) {
        strongest.add(criterion.name);
      }
    }
    
    return strongest;
  }

  /// Get criteria where the best option performs weakest
  List<String> _getWeakestCriteria(Decision decision, Option bestOption) {
    final List<String> weakest = [];
    
    for (final criterion in decision.criteria) {
      final bestScore = bestOption.getScore(criterion.id);
      bool isWeakest = true;
      
      for (final option in decision.options) {
        if (option.id != bestOption.id && option.getScore(criterion.id) <= bestScore) {
          isWeakest = false;
          break;
        }
      }
      
      if (isWeakest && bestScore <= 5) {
        weakest.add(criterion.name);
      }
    }
    
    return weakest;
  }

  /// Calculate completion percentage for a decision
  double calculateCompletionPercentage(Decision decision) {
    if (decision.criteria.isEmpty || decision.options.isEmpty) {
      return 0.0;
    }

    int totalScores = decision.criteria.length * decision.options.length;
    int completedScores = 0;

    for (final option in decision.options) {
      for (final criterion in decision.criteria) {
        if (option.getScore(criterion.id) > 0) {
          completedScores++;
        }
      }
    }

    return completedScores / totalScores;
  }

  /// Validate if a decision is ready for analysis
  bool isDecisionReadyForAnalysis(Decision decision) {
    if (decision.criteria.isEmpty || decision.options.isEmpty) {
      return false;
    }

    // Check if all criteria have weights
    for (final criterion in decision.criteria) {
      if (criterion.weight <= 0) {
        return false;
      }
    }

    // Check if all options have scores for all criteria
    for (final option in decision.options) {
      for (final criterion in decision.criteria) {
        if (option.getScore(criterion.id) <= 0) {
          return false;
        }
      }
    }

    return true;
  }

  /// Get radar chart data for visualization
  Map<String, List<double>> getRadarChartData(Decision decision) {
    final Map<String, List<double>> chartData = {};
    
    if (decision.criteria.isEmpty || decision.options.isEmpty) {
      return chartData;
    }

    for (final option in decision.options) {
      final List<double> scores = [];
      for (final criterion in decision.criteria) {
        scores.add(option.getScore(criterion.id).toDouble());
      }
      chartData[option.name] = scores;
    }

    return chartData;
  }

  /// Get criteria labels for charts
  List<String> getCriteriaLabels(Decision decision) {
    return decision.criteria.map((criterion) => criterion.name).toList();
  }

  /// Normalize weights to ensure they sum to 1.0
  List<Criterion> normalizeWeights(List<Criterion> criteria) {
    if (criteria.isEmpty) return criteria;

    final double totalWeight = criteria.fold(0.0, (sum, criterion) => sum + criterion.weight);
    
    if (totalWeight == 0) return criteria;

    return criteria.map((criterion) {
      return criterion.copyWith(weight: criterion.weight / totalWeight);
    }).toList();
  }

  /// Calculate score difference between top two options
  double getScoreDifference(Decision decision) {
    final scores = calculateScores(decision);
    
    if (scores.length < 2) return 0.0;

    final sortedScores = scores.values.toList()..sort((a, b) => b.compareTo(a));
    
    return sortedScores[0] - sortedScores[1];
  }
}