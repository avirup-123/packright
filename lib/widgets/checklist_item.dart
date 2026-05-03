import 'package:flutter/material.dart';

import '../models/packing_item.dart';
import '../theme/app_theme.dart';

/// Checklist Item Widget - Full Version with Swipe Actions
/// Displays a single packing item with circular checkbox, strikethrough, dimming,
/// swipe-to-delete (left), and swipe-to-edit (right)
class ChecklistItem extends StatefulWidget {
  final PackingItem item;
  final bool isChecked;
  final VoidCallback? onChecked;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onUndo;

  const ChecklistItem({
    super.key,
    required this.item,
    required this.isChecked,
    this.onChecked,
    this.onDelete,
    this.onEdit,
    this.onUndo,
  });

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.item.name);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChecklistItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.name != widget.item.name) {
      _editController.text = widget.item.name;
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    // Focus the text field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_editFieldKey.currentContext != null) {
        FocusScope.of(_editFieldKey.currentContext!).requestFocus(_editFocusNode);
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editController.text = widget.item.name;
    });
  }

  void _saveEdit() {
    final newName = _editController.text.trim();
    if (newName.isNotEmpty && newName != widget.item.name) {
      // Save will be handled by parent via onEdit callback
    }
    setState(() {
      _isEditing = false;
    });
  }

  final FocusNode _editFocusNode = FocusNode();
  final GlobalKey _editFieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('item-${widget.item.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - delete
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right - edit
          _startEditing();
          return false; // Don't dismiss, just start editing
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete?.call();
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: _isEditing
          ? _buildEditRow()
          : _buildItemRow(),
    );
  }

  Widget _buildEditRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 24), // Space for checkbox
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: _editFieldKey,
              controller: _editController,
              focusNode: _editFocusNode,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.textPrimaryLight,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
              onSubmitted: (_) => _saveEdit(),
              onTapOutside: (_) => _cancelEditing(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.primary),
            onPressed: _saveEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow() {
    return InkWell(
      onTap: widget.onChecked,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: widget.isChecked ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Circular Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isChecked ? AppTheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isChecked ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: widget.isChecked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Item Name and Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: widget.isChecked
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimaryLight,
                        decoration: widget.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (widget.item.quantity > 1)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '×${widget.item.quantity}',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                        ),
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