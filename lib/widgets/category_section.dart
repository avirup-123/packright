import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/packing_item.dart';
import '../theme/app_theme.dart';
import '../providers/trip_provider.dart';
import '../services/ai_service.dart';
import 'checklist_item.dart';

/// Category Section Widget - Full Version with Swipe Actions
/// Displays a category with expandable/collapsible items list,
/// swipe-to-delete with undo, and swipe-to-edit
class CategorySection extends StatefulWidget {
  final Category category;
  final String tripId;
  final Set<String> highlightedItems;

  const CategorySection({
    super.key,
    required this.category,
    required this.tripId,
    this.highlightedItems = const {},
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _isExpanded = true;
  PackingItem? _deletedItem;
  int? _deletedItemIndex;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleItem(TripProvider provider, PackingItem item) {
    final updatedItems = widget.category.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(isPacked: !i.isPacked);
      }
      return i;
    }).toList();

    final updatedCategory = widget.category.copyWith(items: updatedItems);
    final trip = provider.getTripById(widget.tripId);

    if (trip != null) {
      final updatedCategories = trip.categories.map((c) {
        if (c.name == widget.category.name && c.iconName == widget.category.iconName) {
          return updatedCategory;
        }
        return c;
      }).toList();

      provider.updateTrip(trip.copyWith(categories: updatedCategories));
    }
  }

  void _deleteItem(PackingItem item) {
    final index = widget.category.items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;

    // Store deleted item and index for undo
    setState(() {
      _deletedItem = item;
      _deletedItemIndex = index;
    });

    // Remove item from category
    final updatedItems = List<PackingItem>.from(widget.category.items)..removeAt(index);
    final updatedCategory = widget.category.copyWith(items: updatedItems);

    // Update trip
    final provider = Provider.of<TripProvider>(context, listen: false);
    final trip = provider.getTripById(widget.tripId);

    if (trip != null) {
      final updatedCategories = trip.categories.map((c) {
        if (c.name == widget.category.name && c.iconName == widget.category.iconName) {
          return updatedCategory;
        }
        return c;
      }).toList();

      provider.updateTrip(trip.copyWith(categories: updatedCategories));
    }

    // Show snackbar with undo option
    _showUndoSnackbar();
  }

  void _editItem(PackingItem item, String newName) {
    if (newName.trim().isEmpty || newName == item.name) return;

    final updatedItems = widget.category.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(name: newName.trim());
      }
      return i;
    }).toList();

    final updatedCategory = widget.category.copyWith(items: updatedItems);

    final provider = Provider.of<TripProvider>(context, listen: false);
    final trip = provider.getTripById(widget.tripId);

    if (trip != null) {
      final updatedCategories = trip.categories.map((c) {
        if (c.name == widget.category.name && c.iconName == widget.category.iconName) {
          return updatedCategory;
        }
        return c;
      }).toList();

      provider.updateTrip(trip.copyWith(categories: updatedCategories));
    }
  }

  void _showUndoSnackbar() {
    _snackBarController?.close();

    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item deleted'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.accent,
          onPressed: _undoDelete,
        ),
        duration: const Duration(seconds: 3),
        onVisible: () {
          // Snackbar is visible
        },
      ),
    );

    // Clear deleted item after snackbar closes
    _snackBarController?.closed.then((reason) {
      if (reason == SnackBarClosedReason.timeout) {
        setState(() {
          _deletedItem = null;
          _deletedItemIndex = null;
        });
      }
    });
  }

  void _undoDelete() {
    if (_deletedItem == null || _deletedItemIndex == null) return;

    // Restore item at original position
    final items = List<PackingItem>.from(widget.category.items);
    items.insert(_deletedItemIndex!, _deletedItem!);

    final updatedCategory = widget.category.copyWith(items: items);

    final provider = Provider.of<TripProvider>(context, listen: false);
    final trip = provider.getTripById(widget.tripId);

    if (trip != null) {
      final updatedCategories = trip.categories.map((c) {
        if (c.name == widget.category.name && c.iconName == widget.category.iconName) {
          return updatedCategory;
        }
        return c;
      }).toList();

      provider.updateTrip(trip.copyWith(categories: updatedCategories));
    }

    setState(() {
      _deletedItem = null;
      _deletedItemIndex = null;
    });

    _snackBarController?.close();
  }

  @override
  void dispose() {
    _snackBarController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if category has no items
    if (widget.category.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final iconData = AIService.getIconForName(widget.category.iconName);
    final packedCount = widget.category.packedCount;
    final totalCount = widget.category.totalCount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          InkWell(
            onTap: _toggleExpand,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconData,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$packedCount/$totalCount packed',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

                  // Items List with smooth animation
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: widget.category.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isHighlighted = widget.highlightedItems.contains('${widget.category.name}-${item.name}');
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: isHighlighted
                        ? const EdgeInsets.symmetric(vertical: 4)
                        : EdgeInsets.zero,
                    padding: isHighlighted ? const EdgeInsets.all(8) : EdgeInsets.zero,
                    decoration: isHighlighted
                        ? BoxDecoration(
                            color: AppTheme.primaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: ChecklistItem(
                      key: Key('item-${item.id}'),
                      item: item,
                      isChecked: item.isPacked,
                      onChecked: () {
                        _toggleItem(
                          Provider.of<TripProvider>(context, listen: false),
                          item,
                        );
                      },
                      onDelete: () {
                        _deleteItem(item);
                      },
                      onEdit: () {
                        // Edit is handled inline in ChecklistItem
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Divider at bottom (when collapsed)
          if (!_isExpanded)
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}