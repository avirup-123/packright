import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../models/packing_item.dart';
import '../models/category.dart';
import '../services/ai_service.dart';
import '../widgets/category_section.dart';
import '../widgets/checklist_fab.dart';

/// Checklist Screen - Full Version with FAB, Share, Menu, and Celebration
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String? _tripId;
  Set<String> _highlightedItems = {};
  bool _hasCelebrated = false;
  bool _showCelebration = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tripId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _tripId = args;
      } else if (args is Map<String, dynamic>) {
        _tripId = args['tripId'] as String?;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tripId == null) {
      return const _ErrorWidget(message: 'No trip selected');
    }

    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        final trip = provider.getTripById(_tripId!);

        if (trip == null) {
          return const _ErrorWidget(message: 'Trip not found');
        }

        final totalItems = trip.totalItems;
        final packedItems = trip.packedItems;
        final isComplete = totalItems > 0 && packedItems == totalItems;
        final progress = totalItems > 0 ? packedItems / totalItems : 0.0;

        // Check for celebration trigger
        if (isComplete && !_hasCelebrated && totalItems > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _showCelebration = true;
              _hasCelebrated = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showCelebration = false;
                });
              }
            });
          });
        } else if (!isComplete) {
          // Reset celebration flag if items become unchecked
          _hasCelebrated = false;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              trip.name,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _sharePackingList(trip),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value, trip, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit trip description'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppTheme.danger),
                        SizedBox(width: 12),
                        Text('Delete trip', style: TextStyle(color: AppTheme.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Progress Summary Bar (fixed)
                  _buildProgressSummary(packedItems, totalItems, progress, isComplete),

                  // Scrollable Checklist Body
                  Expanded(
                    child: trip.categories.isEmpty
                        ? _buildEmptyState()
                        : _buildChecklist(trip),
                  ),
                ],
              ),

              // Celebration overlay
              if (_showCelebration)
                const _CelebrationOverlay(),
            ],
          ),
          floatingActionButton: ChecklistFab(
            onAddManually: () => _showAddItemBottomSheet(trip),
            onAskAI: () => _showAskAIBottomSheet(trip),
          ),
        );
      },
    );
  }

  Widget _buildProgressSummary(
    int packedItems,
    int totalItems,
    double progress,
    bool isComplete,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete
                    ? 'All packed! Have a great trip! 🎉'
                    : '$packedItems of $totalItems items packed',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: isComplete ? FontWeight.w600 : FontWeight.w500,
                  color: isComplete ? AppTheme.success : AppTheme.textPrimaryLight,
                ),
              ),
              if (!isComplete)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppTheme.success : AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: AppTheme.primary,
            ),
            SizedBox(height: 24),
            Text(
              'No packing list generated yet',
              style: TextStyle(
                fontFamily: 'DMSerifDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Your AI-generated packing list will appear here',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(trip) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trip.categories.length + 2, // +2: CTA + bottom spacing
      itemBuilder: (context, index) {
        if (index < trip.categories.length) {
          final category = trip.categories[index];
          return CategorySection(
            key: Key('category-${category.name}-${category.iconName}'),
            category: category,
            tripId: trip.id,
            highlightedItems: _highlightedItems,
          );
        }

        if (index == trip.categories.length) {
          return _buildCTA();
        }

        return const SizedBox(height: 80);
      },
    );
  }

  Widget _buildCTA() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        children: [
          Divider(color: AppTheme.primary.withOpacity(0.15)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.celebration_outlined, size: 20),
              label: const Text(
                "I'm All Packed!",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/congratulations');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Share the packing list as plain text
  void _sharePackingList(trip) {
    final buffer = StringBuffer();
    buffer.writeln('${trip.name} — Packing List');
    buffer.writeln();

    for (final category in trip.categories) {
      if (category.items.isEmpty) continue;

      buffer.writeln('${category.name} (${category.packedCount}/${category.totalCount} packed)');

      for (final item in category.items) {
        final checkbox = item.isPacked ? '✅' : '☐';
        final quantity = item.quantity > 1 ? ' ×${item.quantity}' : '';
        buffer.writeln('$checkbox ${item.name}$quantity');
      }

      buffer.writeln(); // Blank line between categories
    }

    Share.share(buffer.toString(), subject: '${trip.name} — Packing List');
  }

  /// Handle menu actions
  void _handleMenuAction(String action, trip, TripProvider provider) {
    switch (action) {
      case 'edit':
        _showEditConfirmation(trip);
        break;
      case 'delete':
        _showDeleteConfirmation(trip, provider);
        break;
    }
  }

  /// Show edit trip confirmation dialog
  void _showEditConfirmation(trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Trip Description'),
        content: const Text(
          'This will regenerate your packing list. Your current checked items will be lost. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to Trip Input with edit mode
              Navigator.pushNamed(
                context,
                '/trip-input',
                arguments: {
                  'tripId': trip.id,
                  'tripName': trip.name,
                  'description': trip.description,
                  'isEdit': true,
                },
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Show delete trip confirmation dialog
  void _showDeleteConfirmation(trip, TripProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Delete this trip? This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(context);
              provider.deleteTrip(trip.id);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show "Add Item Manually" bottom sheet
  void _showAddItemBottomSheet(trip) {
    final itemNameController = TextEditingController();
    String? selectedCategory;
    final isNewCategory = ValueNotifier<bool>(false);
    final newCategoryController = TextEditingController();
    final categories = trip.categories.map((c) => c.name).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isFormValid = itemNameController.text.trim().isNotEmpty &&
              selectedCategory != null;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add item',
                    style: TextStyle(
                      fontFamily: 'DMSerifDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      hintText: 'Enter item name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: isNewCategory,
                    builder: (context, value, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Select category',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              ...categories.map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(name),
                                  )),
                              const DropdownMenuItem(
                                value: '__new__',
                                child: Text('+ New category'),
                              ),
                            ],
                            onChanged: (value) {
                              setModalState(() {
                                selectedCategory = value;
                                isNewCategory.value = value == '__new__';
                              });
                            },
                          ),
                          if (value) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: newCategoryController,
                              decoration: const InputDecoration(
                                labelText: 'New category name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isFormValid
                        ? () {
                            final provider = Provider.of<TripProvider>(context, listen: false);
                            final itemName = itemNameController.text.trim();

                            if (selectedCategory == '__new__') {
                              final newCategoryName = newCategoryController.text.trim();
                              if (newCategoryName.isEmpty) return;

                              final newCategory = Category(
                                name: newCategoryName,
                                iconName: 'miscellaneous',
                                items: [
                                  PackingItem(
                                    name: itemName,
                                    quantity: 1,
                                    isPacked: false,
                                  ),
                                ],
                              );

                              final updatedTrip = trip.copyWith(
                                categories: [...trip.categories, newCategory],
                              );
                              provider.updateTrip(updatedTrip);
                            } else {
                              final updatedCategories = trip.categories.map((c) {
                                if (c.name == selectedCategory) {
                                  return c.copyWith(
                                    items: [
                                      ...c.items,
                                      PackingItem(
                                        name: itemName,
                                        quantity: 1,
                                        isPacked: false,
                                      ),
                                    ],
                                  );
                                }
                                return c;
                              }).toList();

                              final updatedTrip = trip.copyWith(
                                categories: updatedCategories,
                              );
                              provider.updateTrip(updatedTrip);
                            }

                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show "Ask AI to add more" bottom sheet
  void _showAskAIBottomSheet(trip) {
    final contextController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isFormValid = contextController.text.trim().isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ask AI to add more',
                        style: TextStyle(
                          fontFamily: 'DMSerifDisplay',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: contextController,
                    maxLines: 3,
                    minLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Tell me what else to add',
                      hintText: 'e.g. "also packing for a toddler" or "we\'ll attend a formal dinner"',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      setModalState(() {
                        errorMessage = null;
                      });
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isFormValid && !isLoading
                        ? () async {
                            setModalState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            try {
                              final additionalCategories = await AIService.generateAdditionalItems(
                                trip.description,
                                contextController.text.trim(),
                              );

                              if (!context.mounted) return;

                              final provider = Provider.of<TripProvider>(context, listen: false);
                              final mergedCategories = List<Category>.from(trip.categories);
                              final highlightedItems = <String>{};

                              for (final newCat in additionalCategories) {
                                final existingIndex = mergedCategories.indexWhere(
                                  (c) => c.name.toLowerCase() == newCat.name.toLowerCase(),
                                );

                                if (existingIndex >= 0) {
                                  final existingCat = mergedCategories[existingIndex];
                                  final mergedItems = [...existingCat.items, ...newCat.items];
                                  mergedCategories[existingIndex] = existingCat.copyWith(items: mergedItems);

                                  for (final item in newCat.items) {
                                    highlightedItems.add('${existingCat.name}-${item.name}');
                                  }
                                } else {
                                  mergedCategories.add(newCat);

                                  for (final item in newCat.items) {
                                    highlightedItems.add('${newCat.name}-${item.name}');
                                  }
                                }
                              }

                              final updatedTrip = trip.copyWith(categories: mergedCategories);
                              await provider.updateTrip(updatedTrip);

                              setState(() {
                                _highlightedItems = highlightedItems;
                              });

                              Future.delayed(const Duration(milliseconds: 1500), () {
                                if (mounted) {
                                  setState(() {
                                    _highlightedItems = {};
                                  });
                                }
                              });

                              Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;
                              setModalState(() {
                                isLoading = false;
                                errorMessage = 'Couldn\'t generate items. Try again.';
                              });
                            }
                          }
                        : null,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Generate'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Celebration overlay with falling confetti dots
class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay();

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiDot> _dots = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Generate random confetti dots
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 30; i++) {
      _dots.add(_ConfettiDot(
        x: (random + i * 137) % 1000 / 1000, // Random x position
        delay: i * 50, // Staggered start
        color: [
          AppTheme.primary,
          AppTheme.accent,
          AppTheme.success,
          Colors.pink,
          Colors.orange,
        ][(random + i) % 5],
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _dots.map((dot) {
              final progress = _controller.value;
              final adjustedProgress = (progress * 1000 - dot.delay) / 1500;

              if (adjustedProgress < 0 || adjustedProgress > 1) {
                return const SizedBox.shrink();
              }

              final y = adjustedProgress * MediaQuery.of(context).size.height;
              final opacity = adjustedProgress > 0.8 ? (1 - adjustedProgress) * 5 : 1.0;

              return Positioned(
                left: dot.x * MediaQuery.of(context).size.width,
                top: y,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dot.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _ConfettiDot {
  final double x;
  final int delay;
  final Color color;

  _ConfettiDot({required this.x, required this.delay, required this.color});
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing Checklist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(child: Text(message)),
    );
  }
}