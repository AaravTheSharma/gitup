import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_constants.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/option_model.dart';

import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';
import 'select_criteria_screen.dart';

class CreateDecisionScreen extends StatefulWidget {
  final Map<String, dynamic>? template;

  const CreateDecisionScreen({super.key, this.template});

  @override
  State<CreateDecisionScreen> createState() => _CreateDecisionScreenState();
}

class _CreateDecisionScreenState extends State<CreateDecisionScreen> {
  final _titleController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final List<TextEditingController> _additionalOptionControllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      final template = widget.template!;
      if (template['title'] == 'Custom Decision') {
        _titleController.text = '';
      } else {
        _titleController.text = 'Should I make this ${template['title'].toString().toLowerCase()}?';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    for (final controller in _additionalOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _additionalOptionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _additionalOptionControllers[index].dispose();
      _additionalOptionControllers.removeAt(index);
    });
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final options = <Option>[];
    const uuid = Uuid();

    // Add main options
    if (_option1Controller.text.isNotEmpty) {
      options.add(Option(
        id: uuid.v4(),
        name: _option1Controller.text.trim(),
      ));
    }
    if (_option2Controller.text.isNotEmpty) {
      options.add(Option(
        id: uuid.v4(),
        name: _option2Controller.text.trim(),
      ));
    }

    // Add additional options
    for (final controller in _additionalOptionControllers) {
      if (controller.text.isNotEmpty) {
        options.add(Option(
          id: uuid.v4(),
          name: controller.text.trim(),
        ));
      }
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 options'),
          backgroundColor: Color(AppConstants.dangerColor),
        ),
      );
      return;
    }

    final decision = Decision(
      id: uuid.v4(),
      title: _titleController.text.trim(),
      options: options,
      criteria: [],
      status: AppConstants.statusInProgress,
      creationDate: DateTime.now(),
      category: widget.template?['title'] as String? ?? 'Custom',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectCriteriaScreen(
          decision: decision,
          template: widget.template,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Decision'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decision Title',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Should I change jobs?',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a decision title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                    Text(
                      'Options',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _option1Controller,
                      decoration: const InputDecoration(
                        hintText: 'Option 1 (e.g. Stay at current job)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the first option';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _option2Controller,
                      decoration: const InputDecoration(
                        hintText: 'Option 2 (e.g. Accept new offer)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the second option';
                        }
                        return null;
                      },
                    ),
                    // Additional options
                    ...List.generate(_additionalOptionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _additionalOptionControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 3}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            IconButton(
                              onPressed: () => _removeOption(index),
                              icon: const Icon(Icons.remove_circle, color: Color(AppConstants.dangerColor)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add),
                      label: const Text('Add another option'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        border: Border(
                          left: BorderSide(
                            color: const Color(0xFFF59E0B),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Color(0xFF92400E),
                            size: 16,
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Expanded(
                            child: Text(
                              'Your data remains private. All decisions are stored only on your device.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
      ),
    );
  }
}