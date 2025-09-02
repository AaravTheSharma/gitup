import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_constants.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/criterion_model.dart';
import '../../../logic/decision_service.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import 'set_weights_screen.dart';

class SelectCriteriaScreen extends StatefulWidget {
  final Decision decision;
  final Map<String, dynamic>? template;

  const SelectCriteriaScreen({
    super.key,
    required this.decision,
    this.template,
  });

  @override
  State<SelectCriteriaScreen> createState() => _SelectCriteriaScreenState();
}

class _SelectCriteriaScreenState extends State<SelectCriteriaScreen> {
  final Set<String> _selectedCriteria = {};
  final TextEditingController _customCriteriaController = TextEditingController();
  List<String> _aiSuggestions = [];
  bool _isLoadingAI = false;
  late DecisionService _decisionService;

  @override
  void initState() {
    super.initState();
    _decisionService = DecisionService.getInstance();
    _initializeSelectedCriteria();
    _loadAISuggestions();
  }

  void _initializeSelectedCriteria() {
    if (widget.template != null) {
      final templateCriteria = widget.template!['criteria'] as List<dynamic>? ?? [];
      for (final criteriaName in templateCriteria) {
        _selectedCriteria.add(criteriaName as String);
      }
    } else {
      // Default selection for custom decisions
      _selectedCriteria.addAll(['Salary', 'Growth', 'Happiness']);
    }
  }

  Future<void> _loadAISuggestions() async {
    setState(() {
      _isLoadingAI = true;
    });

    try {
      final suggestions = await _decisionService.getAISuggestedCriteria(
        widget.decision.title,
        widget.decision.category,
      );
      setState(() {
        _aiSuggestions = suggestions;
        _isLoadingAI = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  @override
  void dispose() {
    _customCriteriaController.dispose();
    super.dispose();
  }

  void _toggleCriteria(String criteriaName) {
    setState(() {
      if (_selectedCriteria.contains(criteriaName)) {
        _selectedCriteria.remove(criteriaName);
      } else {
        _selectedCriteria.add(criteriaName);
      }
    });
  }

  void _addCustomCriteria() {
    final customName = _customCriteriaController.text.trim();
    if (customName.isNotEmpty && !_selectedCriteria.contains(customName)) {
      setState(() {
        _selectedCriteria.add(customName);
        _customCriteriaController.clear();
      });
    }
  }

  void _continue() {
    if (_selectedCriteria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one criteria'),
          backgroundColor: Color(AppConstants.dangerColor),
        ),
      );
      return;
    }

    const uuid = Uuid();
    final criteria = _selectedCriteria.map((name) {
      // Find matching default criteria for icon
      final defaultCriteria = AppConstants.defaultCriteria
          .firstWhere((c) => c['name'] == name, orElse: () => {'icon': 'circle'});
      
      return Criterion(
        id: uuid.v4(),
        name: name,
        weight: 1.0, // Default weight, will be set in next screen
        icon: defaultCriteria['icon'] as String,
      );
    }).toList();

    final updatedDecision = widget.decision.copyWith(criteria: criteria);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SetWeightsScreen(decision: updatedDecision),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Criteria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Evaluation Criteria',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Choose what matters most to you. These criteria will be used to compare your options.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  
                  // AI Suggestions Section
                  if (_aiSuggestions.isNotEmpty || _isLoadingAI) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'AI Suggestions',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (_isLoadingAI) ...[
                          const SizedBox(width: AppConstants.paddingSmall),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    if (_isLoadingAI)
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        child: Text(
                          'AI is analyzing your decision to suggest relevant criteria...',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _aiSuggestions.map((name) {
                          final isSelected = _selectedCriteria.contains(name);
                          
                          return GestureDetector(
                            onTap: () => _toggleCriteria(name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingMedium,
                                vertical: AppConstants.paddingSmall,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Common Criteria',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                  ],
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.defaultCriteria.map((criteria) {
                      final name = criteria['name'] as String;
                      final icon = criteria['icon'] as String;
                      final isSelected = _selectedCriteria.contains(name);
                      
                      return GestureDetector(
                        onTap: () => _toggleCriteria(name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Helpers.getCriterionIcon(icon),
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customCriteriaController,
                          decoration: const InputDecoration(
                            hintText: 'Add custom criteria',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addCustomCriteria(),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      IconButton(
                        onPressed: _addCustomCriteria,
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedCriteria.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Selected: ${_selectedCriteria.length} criteria',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.paddingXLarge),
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: _continue,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}