import 'package:flutter/material.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/decision_list_item.dart';
import '../new_decision/templates_screen.dart';
import '../report/report_screen.dart';
import '../ai_analysis/ai_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Decision> _decisions = [];
  bool _isLoading = true;
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _loadDecisions();
  }

  Future<void> _loadDecisions() async {
    if (_storageService == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final decisions = await _storageService!.loadDecisions();
      setState(() {
        _decisions = decisions
            .where((decision) => !decision.isArchived)
            .toList()
          ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading decisions: $e')),
        );
      }
    }
  }

  void _navigateToNewDecision() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TemplatesScreen(),
      ),
    ).then((_) => _loadDecisions());
  }

  void _navigateToAIAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AIAnalysisScreen(),
      ),
    );
  }

  void _navigateToReport(Decision decision) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportScreen(decision: decision),
      ),
    ).then((_) => _loadDecisions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadDecisions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Clarity',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Navigate your choices. With clarity and privacy.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Welcome Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Ready to clarify your next important decision?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'New Decision',
                            icon: Icons.add_circle,
                            onPressed: _navigateToNewDecision,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: PrimaryButton(
                            text: 'AI Assist',
                            icon: Icons.psychology,
                            onPressed: _navigateToAIAnalysis,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Recent Decisions Section
              Text(
                'Recent Decisions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Loading State
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingXLarge),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Empty State
              if (!_isLoading && _decisions.isEmpty)
                CustomCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 64,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'No decisions yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Create your first decision to get started with structured decision-making.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      PrimaryButton(
                        text: 'Get Started',
                        onPressed: _navigateToNewDecision,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),

              // Decisions List
              if (!_isLoading && _decisions.isNotEmpty)
                ...(_decisions.take(5).map((decision) => DecisionListItem(
                  decision: decision,
                  onTap: () => _navigateToReport(decision),
                ))),

              // Show More Button
              if (!_isLoading && _decisions.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to full list or show more
                      },
                      child: Text(
                        'View All (${_decisions.length})',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }
}