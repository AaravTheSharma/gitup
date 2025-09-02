import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/decision_model.dart';

class AIService {
  static AIService? _instance;
  static const String _baseUrl = 'https://api.deepseek.com/chat/completions';
  static const String _apiKey = 'sk-4482f345cc9e4270b61e94558047afa3';

  AIService._();

  static AIService getInstance() {
    _instance ??= AIService._();
    return _instance!;
  }

  /// Multi-dimensional question analysis - Core functionality
  Future<Map<String, dynamic>> analyzeQuestionMultiDimensional(
    String question,
  ) async {
    try {
      final prompt = _buildMultiDimensionalAnalysisPrompt(question);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a professional decision analyst. When users present questions, you need to conduct in-depth analysis from multiple dimensions to help users comprehensively understand the problem and make informed decisions.

Please return analysis results in JSON format according to the following structure:
{
  "problemType": "Problem type classification",
  "urgency": "Urgency level (1-5)",
  "complexity": "Complexity level (1-5)",
  "stakeholders": ["Related stakeholders"],
  "dimensions": {
    "financial": "Financial dimension analysis",
    "emotional": "Emotional dimension analysis", 
    "social": "Social relationship dimension analysis",
    "career": "Career development dimension analysis",
    "health": "Health dimension analysis",
    "time": "Time dimension analysis",
    "risk": "Risk dimension analysis",
    "opportunity": "Opportunity dimension analysis"
  },
  "keyFactors": ["Key influencing factors"],
  "alternatives": ["Possible solution options"],
  "recommendations": ["Specific recommendations"],
  "nextSteps": ["Next action steps"],
  "considerations": ["Points to consider"],
  "timeline": "Recommended decision timeframe"
}

Ensure the analysis is comprehensive, practical, and targeted.''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;

        try {
          // Try to parse JSON response
          final analysisResult = jsonDecode(content);
          return analysisResult;
        } catch (e) {
          // If JSON parsing fails, return text analysis
          return _parseTextAnalysis(content);
        }
      } else {
        return _getFallbackMultiDimensionalAnalysis(question);
      }
    } catch (e) {
      debugPrint('Multi-dimensional Analysis Error: $e');
      return _getFallbackMultiDimensionalAnalysis(question);
    }
  }

  /// Generate decision framework recommendations
  Future<Map<String, dynamic>> generateDecisionFramework(
    String question,
  ) async {
    try {
      final prompt = _buildDecisionFrameworkPrompt(question);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a decision framework expert. Based on user questions, design a structured decision framework for them.

Return in JSON format:
{
  "framework": "Recommended decision framework name",
  "description": "Framework description",
  "steps": ["Step 1", "Step 2", "Step 3"],
  "criteria": ["Evaluation criterion 1", "Evaluation criterion 2"],
  "weights": {"Criterion 1": 0.3, "Criterion 2": 0.4},
  "tools": ["Recommended tools or methods"],
  "timeline": "Suggested decision timeline"
}''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 1500,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;

        try {
          return jsonDecode(content);
        } catch (e) {
          return _getFallbackDecisionFramework(question);
        }
      } else {
        return _getFallbackDecisionFramework(question);
      }
    } catch (e) {
      debugPrint('Decision Framework Error: $e');
      return _getFallbackDecisionFramework(question);
    }
  }

  /// Risk assessment analysis
  Future<Map<String, dynamic>> analyzeRisks(
    String question,
    List<String> options,
  ) async {
    try {
      final prompt = _buildRiskAnalysisPrompt(question, options);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a risk analysis expert. Analyze potential risks and opportunities for each option.

Return in JSON format:
{
  "overallRisk": "Overall risk assessment",
  "risksByOption": {
    "Option name": {
      "risks": ["Risk 1", "Risk 2"],
      "opportunities": ["Opportunity 1", "Opportunity 2"],
      "riskLevel": "High/Medium/Low",
      "mitigation": ["Mitigation measure 1", "Mitigation measure 2"]
    }
  },
  "recommendations": ["Risk management recommendations"]
}''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 1500,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;

        try {
          return jsonDecode(content);
        } catch (e) {
          return _getFallbackRiskAnalysis(question, options);
        }
      } else {
        return _getFallbackRiskAnalysis(question, options);
      }
    } catch (e) {
      debugPrint('Risk Analysis Error: $e');
      return _getFallbackRiskAnalysis(question, options);
    }
  }

  /// Generate AI-powered analysis for a decision
  Future<String> generateDecisionAnalysis(Decision decision) async {
    try {
      final prompt = _buildAnalysisPrompt(decision);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional decision analysis assistant. Provide clear, structured, and actionable insights for complex decisions. Focus on being practical and helpful.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        debugPrint('AI API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackAnalysis(decision);
      }
    } catch (e) {
      debugPrint('AI Service Error: $e');
      return _getFallbackAnalysis(decision);
    }
  }

  /// Generate AI suggestions for criteria based on decision type
  Future<List<String>> suggestCriteria(
    String decisionTitle,
    String category,
  ) async {
    try {
      final prompt = _buildCriteriaSuggestionPrompt(decisionTitle, category);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a decision analysis expert. Suggest 5-8 relevant evaluation criteria for the given decision. Return only the criteria names, one per line, without numbers or explanations.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 200,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .take(8)
            .toList();
      } else {
        return _getFallbackCriteria(category);
      }
    } catch (e) {
      debugPrint('AI Criteria Suggestion Error: $e');
      return _getFallbackCriteria(category);
    }
  }

  /// Generate AI insights for decision patterns
  Future<String> generateInsights(List<Decision> decisions) async {
    if (decisions.isEmpty) {
      return 'Complete some decisions to get personalized insights about your decision-making patterns.';
    }

    try {
      final prompt = _buildInsightsPrompt(decisions);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a behavioral analyst specializing in decision-making patterns. Analyze the user\'s decision history and provide insights about their preferences and patterns.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 800,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        return _getFallbackInsights(decisions);
      }
    } catch (e) {
      debugPrint('AI Insights Error: $e');
      return _getFallbackInsights(decisions);
    }
  }

  String _buildAnalysisPrompt(Decision decision) {
    final buffer = StringBuffer();
    buffer.writeln('Analyze this decision: "${decision.title}"');
    buffer.writeln('\nOptions:');
    for (int i = 0; i < decision.options.length; i++) {
      buffer.writeln('${i + 1}. ${decision.options[i].name}');
    }

    buffer.writeln('\nEvaluation Criteria and Scores:');
    for (final criterion in decision.criteria) {
      buffer.writeln(
        '\n${criterion.name} (Weight: ${(criterion.weight * 100).round()}%):',
      );
      for (final option in decision.options) {
        final score = option.getScore(criterion.id);
        buffer.writeln('  - ${option.name}: $score/10');
      }
    }

    buffer.writeln('\nPlease provide:');
    buffer.writeln('1. A clear recommendation with reasoning');
    buffer.writeln('2. Key strengths and weaknesses of each option');
    buffer.writeln('3. Important factors to consider');
    buffer.writeln('4. Potential risks and opportunities');
    buffer.writeln('\nKeep the analysis practical and actionable.');

    return buffer.toString();
  }

  String _buildCriteriaSuggestionPrompt(String decisionTitle, String category) {
    return 'For the decision "$decisionTitle" in the $category category, suggest relevant evaluation criteria that would help make an informed choice.';
  }

  String _buildInsightsPrompt(List<Decision> decisions) {
    final buffer = StringBuffer();
    buffer.writeln('Analyze these decision-making patterns:');

    final criteriaCount = <String, int>{};
    final categoryCount = <String, int>{};

    for (final decision in decisions.take(10)) {
      buffer.writeln('\nDecision: ${decision.title}');
      buffer.writeln('Category: ${decision.category}');
      buffer.writeln('Status: ${decision.status}');

      categoryCount[decision.category] =
          (categoryCount[decision.category] ?? 0) + 1;

      for (final criterion in decision.criteria) {
        criteriaCount[criterion.name] =
            (criteriaCount[criterion.name] ?? 0) + 1;
      }
    }

    buffer.writeln(
      '\nMost used criteria: ${criteriaCount.entries.take(5).map((e) => '${e.key} (${e.value}x)').join(', ')}',
    );
    buffer.writeln(
      'Decision categories: ${categoryCount.entries.map((e) => '${e.key} (${e.value})').join(', ')}',
    );

    buffer.writeln('\nProvide insights about:');
    buffer.writeln('1. Decision-making patterns and preferences');
    buffer.writeln('2. Most valued criteria and what this reveals');
    buffer.writeln('3. Suggestions for improvement');
    buffer.writeln('4. Potential blind spots to consider');

    return buffer.toString();
  }

  String _getFallbackAnalysis(Decision decision) {
    // Calculate basic scores for fallback
    final scores = <String, double>{};
    for (final option in decision.options) {
      double totalScore = 0;
      double totalWeight = 0;

      for (final criterion in decision.criteria) {
        final score = option.getScore(criterion.id);
        totalScore += score * criterion.weight;
        totalWeight += criterion.weight;
      }

      scores[option.name] = totalWeight > 0 ? totalScore / totalWeight : 0;
    }

    final sortedOptions = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer();
    buffer.writeln('Decision Analysis for: ${decision.title}');
    buffer.writeln('\nRecommendation: ${sortedOptions.first.key}');
    buffer.writeln('Score: ${sortedOptions.first.value.toStringAsFixed(1)}/10');

    buffer.writeln('\nOption Comparison:');
    for (final entry in sortedOptions) {
      buffer.writeln('• ${entry.key}: ${entry.value.toStringAsFixed(1)}/10');
    }

    buffer.writeln('\nKey Considerations:');
    buffer.writeln(
      '• Review your scoring to ensure it reflects your true priorities',
    );
    buffer.writeln(
      '• Consider long-term implications beyond the current criteria',
    );
    buffer.writeln('• Think about potential risks and backup plans');
    buffer.writeln('• Trust your intuition alongside the analytical results');

    return buffer.toString();
  }

  List<String> _getFallbackCriteria(String category) {
    switch (category.toLowerCase()) {
      case 'career decision':
        return [
          'Salary',
          'Growth Opportunities',
          'Work-Life Balance',
          'Company Culture',
          'Job Security',
          'Learning Potential',
        ];
      case 'housing decision':
        return [
          'Cost',
          'Location',
          'Size',
          'Commute Time',
          'Neighborhood Safety',
          'Future Value',
        ];
      case 'financial decision':
        return [
          'Cost',
          'Return on Investment',
          'Risk Level',
          'Liquidity',
          'Time Horizon',
          'Tax Implications',
        ];
      case 'relationship decision':
        return [
          'Compatibility',
          'Trust',
          'Communication',
          'Shared Values',
          'Future Goals',
          'Emotional Connection',
        ];
      default:
        return [
          'Cost',
          'Benefits',
          'Risk',
          'Time Investment',
          'Long-term Impact',
          'Personal Satisfaction',
        ];
    }
  }

  String _getFallbackInsights(List<Decision> decisions) {
    final criteriaCount = <String, int>{};
    final categoryCount = <String, int>{};

    for (final decision in decisions) {
      categoryCount[decision.category] =
          (categoryCount[decision.category] ?? 0) + 1;
      for (final criterion in decision.criteria) {
        criteriaCount[criterion.name] =
            (criteriaCount[criterion.name] ?? 0) + 1;
      }
    }

    final topCriteria = criteriaCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer();
    buffer.writeln('Your Decision-Making Insights:');

    if (topCriteria.isNotEmpty) {
      buffer.writeln('\nMost Important Criteria:');
      for (final entry in topCriteria.take(3)) {
        buffer.writeln('• ${entry.key} (used ${entry.value} times)');
      }
    }

    if (topCategories.isNotEmpty) {
      buffer.writeln('\nDecision Focus Areas:');
      for (final entry in topCategories.take(3)) {
        buffer.writeln('• ${entry.key}: ${entry.value} decisions');
      }
    }

    buffer.writeln('\nRecommendations:');
    buffer.writeln(
      '• Continue using structured decision-making for complex choices',
    );
    buffer.writeln(
      '• Consider if you\'re giving enough weight to emotional factors',
    );
    buffer.writeln('• Review past decisions to learn from outcomes');
    buffer.writeln(
      '• Don\'t forget to trust your intuition alongside analysis',
    );

    return buffer.toString();
  }

  // New helper methods
  String _buildMultiDimensionalAnalysisPrompt(String question) {
    return '''
Please conduct a multi-dimensional in-depth analysis of the following question:

Question: $question

Please analyze from the following dimensions:
1. Financial Impact - Cost, benefits, return on investment
2. Emotional Factors - Psychological feelings, stress, satisfaction
3. Social Relationships - Impact on interpersonal relationships
4. Career Development - Short and long-term impact on career
5. Health Impact - Physical and mental health considerations
6. Time Factors - Time investment, urgency
7. Risk Assessment - Potential risks and uncertainties
8. Opportunity Cost - Other opportunities given up by choosing this option

Please provide structured analysis including:
- Problem classification and urgency level
- Related stakeholders
- Specific analysis for each dimension
- Key influencing factors
- Possible solutions
- Specific recommendations and next steps
''';
  }

  String _buildDecisionFrameworkPrompt(String question) {
    return '''
Based on the following question, please recommend the most suitable decision framework:

Question: $question

Please consider:
1. Complexity level of the problem
2. Number of stakeholders involved
3. Importance and impact scope of the decision
4. Available time and resources
5. Level of uncertainty

Recommend an appropriate decision framework (such as SWOT analysis, decision tree, cost-benefit analysis, multi-criteria decision analysis, etc.), and provide:
- Specific steps of the framework
- Evaluation criteria and weight recommendations
- Implementation tools and methods
- Timeline recommendations
''';
  }

  String _buildRiskAnalysisPrompt(String question, List<String> options) {
    final optionsText = options.map((option) => '• $option').join('\n');

    return '''
Please conduct a risk analysis for the following decision:

Question: $question

Available options:
$optionsText

Please analyze:
1. Main risks of each option
2. Potential opportunities of each option
3. Probability and impact level of risks
4. Risk mitigation measures
5. Overall risk assessment and recommendations
''';
  }

  Map<String, dynamic> _parseTextAnalysis(String content) {
    // Simple text parsing logic to extract key information
    return {
      'problemType': 'Complex Decision',
      'urgency': '3',
      'complexity': '4',
      'stakeholders': ['User'],
      'dimensions': {'analysis': content},
      'keyFactors': ['Requires further analysis'],
      'alternatives': ['Need to clarify options'],
      'recommendations': ['Recommend using structured decision methods'],
      'nextSteps': ['Gather more information', 'Clarify evaluation criteria'],
      'considerations': ['Consider multi-dimensional impacts'],
      'timeline': 'Recommend making decision after thorough analysis',
    };
  }

  Map<String, dynamic> _getFallbackMultiDimensionalAnalysis(String question) {
    return {
      'problemType': 'General Decision Problem',
      'urgency': '3',
      'complexity': '3',
      'stakeholders': ['Decision Maker'],
      'dimensions': {
        'financial': 'Need to assess financial impact',
        'emotional': 'Consider emotional factors and psychological feelings',
        'social': 'Evaluate impact on interpersonal relationships',
        'career': 'Consider impact on career development',
        'health': 'Assess impact on physical and mental health',
        'time': 'Consider time investment and urgency',
        'risk': 'Identify and assess potential risks',
        'opportunity': 'Analyze opportunity costs and potential benefits',
      },
      'keyFactors': [
        'Personal values',
        'Resource availability',
        'Time constraints',
        'Risk tolerance',
      ],
      'alternatives': ['To be determined after gathering more information'],
      'recommendations': [
        'Clarify decision objectives and priorities',
        'Gather relevant information and data',
        'Consult relevant experts or experienced individuals',
        'Use structured decision-making tools',
      ],
      'nextSteps': [
        'Define clear decision criteria',
        'List all possible options',
        'Evaluate pros and cons of each option',
        'Make decision and create implementation plan',
      ],
      'considerations': [
        'Consider long-term and short-term impacts',
        'Assess uncertainty and risks',
        'Consider reversibility and flexibility',
        'Focus on core value alignment',
      ],
      'timeline': 'Recommend spending appropriate time for thorough analysis',
    };
  }

  Map<String, dynamic> _getFallbackDecisionFramework(String question) {
    return {
      'framework': 'Multi-Criteria Decision Analysis (MCDA)',
      'description':
          'Structured approach suitable for complex decisions, evaluating different options through multiple criteria',
      'steps': [
        'Clarify decision objectives',
        'Identify all feasible options',
        'Determine evaluation criteria',
        'Assign weights to criteria',
        'Evaluate each option',
        'Calculate composite scores',
        'Make final decision',
      ],
      'criteria': [
        'Cost-benefit',
        'Feasibility',
        'Risk level',
        'Time requirements',
        'Resource needs',
      ],
      'weights': {
        'Cost-benefit': 0.25,
        'Feasibility': 0.20,
        'Risk level': 0.20,
        'Time requirements': 0.15,
        'Resource needs': 0.20,
      },
      'tools': ['Decision matrix', 'Weight analysis', 'Sensitivity analysis'],
      'timeline': '1-2 weeks for thorough analysis and evaluation',
    };
  }

  Map<String, dynamic> _getFallbackRiskAnalysis(
    String question,
    List<String> options,
  ) {
    final risksByOption = <String, dynamic>{};

    for (final option in options) {
      risksByOption[option] = {
        'risks': ['Uncertainty risk', 'Implementation risk'],
        'opportunities': ['Potential benefits', 'Learning opportunities'],
        'riskLevel': 'Medium',
        'mitigation': ['Develop alternative plans', 'Phased implementation'],
      };
    }

    return {
      'overallRisk': 'Medium risk, requires careful evaluation',
      'risksByOption': risksByOption,
      'recommendations': [
        'Conduct detailed risk assessment',
        'Develop risk mitigation plans',
        'Establish monitoring mechanisms',
        'Prepare contingency plans',
      ],
    };
  }
}
