import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../data/services/ai_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  final _questionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _frameworkResult;
  Map<String, dynamic>? _riskResult;

  final AIService _aiService = AIService.getInstance();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _analyzeQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
      _frameworkResult = null;
      _riskResult = null;
    });

    try {
      final question = _questionController.text.trim();

      // 并行执行多个分析
      final futures = await Future.wait([
        _aiService.analyzeQuestionMultiDimensional(question),
        _aiService.generateDecisionFramework(question),
      ]);

      setState(() {
        _analysisResult = futures[0];
        _frameworkResult = futures[1];
        _isAnalyzing = false;
      });

      // 如果有选项，进行风险分析
      if (_analysisResult?['alternatives'] != null) {
        final alternatives = List<String>.from(
          _analysisResult!['alternatives'],
        );
        if (alternatives.isNotEmpty) {
          final riskAnalysis = await _aiService.analyzeRisks(
            question,
            alternatives,
          );
          setState(() {
            _riskResult = riskAnalysis;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis error: $e'),
            backgroundColor: const Color(AppConstants.dangerColor),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Decision Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 输入区域
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe Your Decision',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _questionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Should I change jobs? My current job is stable but has limited growth opportunities, while the new opportunity offers higher salary but more risk...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your decision question';
                        }
                        if (value.trim().length < 5) {
                          return 'Please provide more details about your decision';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    PrimaryButton(
                      text: _isAnalyzing ? 'Analyzing...' : 'Start AI Analysis',
                      onPressed: _isAnalyzing ? null : _analyzeQuestion,
                      width: double.infinity,
                      icon: _isAnalyzing ? null : Icons.psychology,
                    ),
                  ],
                ),
              ),

              if (_isAnalyzing) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppConstants.paddingMedium),
                      Text('AI is analyzing your decision from multiple dimensions...'),
                    ],
                  ),
                ),
              ],

              // 分析结果
              if (_analysisResult != null) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                _buildAnalysisResults(),
              ],

              // 决策框架建议
              if (_frameworkResult != null) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                _buildFrameworkResults(),
              ],

              // 风险分析
              if (_riskResult != null) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                _buildRiskResults(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final analysis = _analysisResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Analysis Results',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // 问题概览卡片
        _buildOverviewCard(analysis),
        const SizedBox(height: AppConstants.paddingMedium),

        // 分析要点 - 替代复杂的维度分析
        _buildAnalysisHighlights(analysis),
        const SizedBox(height: AppConstants.paddingMedium),

        // Key insights
        _buildInsightsCard(analysis),
      ],
    );
  }

  Widget _buildFrameworkResults() {
    final framework = _frameworkResult!;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_tree, color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '推荐决策框架',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      framework['framework'] ?? '结构化决策方法',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          if (framework['description'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
              ),
              child: Text(
                framework['description'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          if (framework['steps'] != null) ...[
            Row(
              children: [
                Icon(Icons.list_alt, size: 16, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  '实施步骤',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...List<String>.from(framework['steps']).asMap().entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskResults() {
    final risk = _riskResult!;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '风险分析',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // 整体风险评估
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.assessment, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '整体评估: ${risk['overallRisk'] ?? '需要进一步评估'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // 风险管理建议
          if (risk['recommendations'] != null) ...[
            Row(
              children: [
                Icon(Icons.shield, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '风险管理建议',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...List<String>.from(risk['recommendations']).map(
              (rec) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 选项风险对比
          if (risk['risksByOption'] != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Icon(Icons.compare_arrows, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '选项风险对比',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...Map<String, dynamic>.from(risk['risksByOption']).entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (entry.value['riskLevel'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 14,
                            color: _getRiskLevelColor(entry.value['riskLevel']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '风险等级: ${entry.value['riskLevel']}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _getRiskLevelColor(
                                    entry.value['riskLevel'],
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRiskLevelColor(String level) {
    switch (level.toLowerCase()) {
      case '低':
      case 'low':
        return Colors.green;
      case '中':
      case '中等':
      case 'medium':
        return Colors.orange;
      case '高':
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOverviewCard(Map<String, dynamic> analysis) {
    final urgency = int.tryParse(analysis['urgency']?.toString() ?? '0') ?? 0;
    final complexity =
        int.tryParse(analysis['complexity']?.toString() ?? '0') ?? 0;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assessment,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decision Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      analysis['problemType'] ?? 'Unclassified',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Urgency level indicator
          _buildLevelIndicator(
            'Urgency Level',
            urgency,
            Icons.schedule,
            _getUrgencyColor(urgency),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Complexity level indicator
          _buildLevelIndicator(
            'Complexity Level',
            complexity,
            Icons.psychology,
            _getComplexityColor(complexity),
          ),

          if (analysis['timeline'] != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      analysis['timeline'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(
    String label,
    int level,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 20,
                height: 6,
                decoration: BoxDecoration(
                  color: index < level ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
        Text(
          '$level/5',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionsCard(Map<String, dynamic> dimensions) {
    // 过滤掉原始JSON数据，只显示有意义的维度分析
    final filteredDimensions = <String, dynamic>{};

    dimensions.forEach((key, value) {
      // 跳过包含JSON格式或过于技术性的内容
      final valueStr = value.toString();
      if (!valueStr.contains('{') &&
          !valueStr.contains('"') &&
          !valueStr.contains('problemType') &&
          valueStr.length > 10 &&
          valueStr.length < 500) {
        filteredDimensions[key] = value;
      }
    });

    // 如果没有有效的维度数据，不显示这个卡片
    if (filteredDimensions.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.view_module, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '多维度分析',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // 维度列表（改为垂直布局，更适合文本内容）
          ...filteredDimensions.entries.map(
            (entry) => _buildDimensionItem(entry.key, entry.value.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionItem(String key, String value) {
    final dimensionConfig = {
      'financial': {
        'icon': Icons.attach_money,
        'color': Colors.green,
        'title': '💰 财务影响',
      },
      'emotional': {
        'icon': Icons.favorite,
        'color': Colors.red,
        'title': '❤️ 情感因素',
      },
      'social': {
        'icon': Icons.people,
        'color': Colors.blue,
        'title': '👥 社会关系',
      },
      'career': {
        'icon': Icons.work,
        'color': Colors.orange,
        'title': '🚀 职业发展',
      },
      'health': {
        'icon': Icons.health_and_safety,
        'color': Colors.teal,
        'title': '🏥 健康影响',
      },
      'time': {
        'icon': Icons.schedule,
        'color': Colors.purple,
        'title': '⏰ 时间因素',
      },
      'risk': {
        'icon': Icons.warning,
        'color': Colors.amber,
        'title': '⚠️ 风险评估',
      },
      'opportunity': {
        'icon': Icons.trending_up,
        'color': Colors.indigo,
        'title': '🎯 机会分析',
      },
      'analysis': {
        'icon': Icons.analytics,
        'color': Colors.grey,
        'title': '📊 综合分析',
      },
    };

    final config =
        dimensionConfig[key] ??
        {'icon': Icons.help, 'color': Colors.grey, 'title': key};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                config['icon'] as IconData,
                color: config['color'] as Color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                config['title'] as String,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: config['color'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(Map<String, dynamic> analysis) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Key Insights',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Key factors
          if (analysis['keyFactors'] != null) ...[
            _buildInsightSection(
              'Key Factors',
              List<String>.from(analysis['keyFactors']),
              Icons.key,
              Colors.orange,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // AI recommendations
          if (analysis['recommendations'] != null) ...[
            _buildInsightSection(
              'AI Recommendations',
              List<String>.from(analysis['recommendations']),
              Icons.recommend,
              Colors.blue,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Next steps
          if (analysis['nextSteps'] != null) ...[
            _buildInsightSection(
              'Next Steps',
              List<String>.from(analysis['nextSteps']),
              Icons.arrow_forward,
              Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getUrgencyColor(int level) {
    if (level <= 2) return Colors.green;
    if (level <= 3) return Colors.orange;
    return Colors.red;
  }

  Color _getComplexityColor(int level) {
    if (level <= 2) return Colors.blue;
    if (level <= 3) return Colors.purple;
    return Colors.indigo;
  }

  // 分析要点 - 简洁版本替代复杂的维度分析
  Widget _buildAnalysisHighlights(Map<String, dynamic> analysis) {
    final highlights = <Map<String, dynamic>>[];

    // 从不同字段提取关键信息
    if (analysis['stakeholders'] != null) {
      highlights.add({
        'icon': Icons.people,
        'color': Colors.blue,
        'title': '相关人员',
        'content': List<String>.from(analysis['stakeholders']).join('、'),
      });
    }

    if (analysis['alternatives'] != null &&
        List<String>.from(analysis['alternatives']).isNotEmpty) {
      highlights.add({
        'icon': Icons.alt_route,
        'color': Colors.green,
        'title': '可选方案',
        'content': List<String>.from(
          analysis['alternatives'],
        ).take(3).join('、'),
      });
    }

    if (analysis['considerations'] != null) {
      highlights.add({
        'icon': Icons.psychology,
        'color': Colors.purple,
        'title': '重要考虑',
        'content': List<String>.from(
          analysis['considerations'],
        ).take(2).join('；'),
      });
    }

    // 如果没有有效的要点，不显示这个卡片
    if (highlights.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.insights, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '分析要点',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          ...highlights.map(
            (highlight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (highlight['color'] as Color).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (highlight['color'] as Color).withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    highlight['icon'] as IconData,
                    color: highlight['color'] as Color,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          highlight['title'] as String,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: highlight['color'] as Color,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          highlight['content'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 验证维度数据是否有效
  bool _hasValidDimensions(Map<String, dynamic> dimensions) {
    if (dimensions.isEmpty) return false;

    // 检查是否有至少一个有效的维度分析
    for (final entry in dimensions.entries) {
      final valueStr = entry.value.toString();
      if (!valueStr.contains('{') &&
          !valueStr.contains('"') &&
          !valueStr.contains('problemType') &&
          valueStr.length > 10 &&
          valueStr.length < 500) {
        return true;
      }
    }
    return false;
  }
}
