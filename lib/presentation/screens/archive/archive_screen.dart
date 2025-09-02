import 'package:flutter/material.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/app_constants.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/decision_list_item.dart';
import '../report/report_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Decision> _archivedDecisions = [];
  bool _isLoading = true;
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _loadArchivedDecisions();
  }

  Future<void> _loadArchivedDecisions() async {
    if (_storageService == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final decisions = await _storageService!.loadDecisions();
      setState(() {
        _archivedDecisions = decisions
            .where((decision) => decision.isArchived)
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
          SnackBar(content: Text('Error loading archived decisions: $e')),
        );
      }
    }
  }

  void _navigateToReport(Decision decision) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportScreen(decision: decision),
      ),
    ).then((_) => _loadArchivedDecisions());
  }

  Future<void> _unarchiveDecision(Decision decision) async {
    if (_storageService == null) return;

    try {
      final updatedDecision = decision.copyWith(
        status: AppConstants.statusCompleted,
      );
      await _storageService!.saveDecision(updatedDecision);
      await _loadArchivedDecisions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Decision restored from archive')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring decision: $e')),
        );
      }
    }
  }

  Future<void> _deleteDecision(Decision decision) async {
    if (_storageService == null) return;

    final confirmed = await Helpers.showConfirmationDialog(
      context,
      'Delete Decision',
      'Are you sure you want to permanently delete "${decision.title}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    try {
      await _storageService!.deleteDecision(decision.id);
      await _loadArchivedDecisions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Decision deleted permanently')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting decision: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadArchivedDecisions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Archive',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your completed and archived decisions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingXLarge),
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (!_isLoading && _archivedDecisions.isEmpty)
                CustomCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 64,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'No archived decisions',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Completed decisions that you archive will appear here.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              if (!_isLoading && _archivedDecisions.isNotEmpty)
                ...(_archivedDecisions.map((decision) => GestureDetector(
                  onLongPress: () => _showDecisionOptions(decision),
                  child: DecisionListItem(
                    decision: decision,
                    onTap: () => _navigateToReport(decision),
                    showProgress: false,
                  ),
                ))),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showDecisionOptions(Decision decision) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              decision.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingXLarge),
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('Restore from Archive'),
              onTap: () {
                Navigator.of(context).pop();
                _unarchiveDecision(decision);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Report'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToReport(decision);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(AppConstants.dangerColor)),
              title: const Text(
                'Delete Permanently',
                style: TextStyle(color: Color(AppConstants.dangerColor)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _deleteDecision(decision);
              },
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
        ),
      ),
    );
  }
}