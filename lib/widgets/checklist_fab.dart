import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Expandable FAB Widget
/// A Floating Action Button that expands to reveal two options:
/// "Add item manually" and "Ask AI to add more"
class ChecklistFab extends StatefulWidget {
  final VoidCallback? onAddManually;
  final VoidCallback? onAskAI;

  const ChecklistFab({
    super.key,
    this.onAddManually,
    this.onAskAI,
  });

  @override
  State<ChecklistFab> createState() => _ChecklistFabState();
}

class _ChecklistFabState extends State<ChecklistFab> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _collapse() {
    if (_isExpanded) {
      _toggleExpand();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Dark overlay when expanded
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _collapse,
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),

        // Expanded options
        if (_isExpanded) ...[
          // "Ask AI" option (bottom)
          SlideTransition(
            position: _slideAnimation2,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 130, right: 16),
                child: _buildOptionButton(
                  icon: Icons.auto_awesome,
                  label: 'Ask AI',
                  onTap: () {
                    _collapse();
                    widget.onAskAI?.call();
                  },
                ),
              ),
            ),
          ),

          // "Add manually" option (top)
          SlideTransition(
            position: _slideAnimation1,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80, right: 16),
                child: _buildOptionButton(
                  icon: Icons.edit,
                  label: 'Add manually',
                  onTap: () {
                    _collapse();
                    widget.onAddManually?.call();
                  },
                ),
              ),
            ),
          ),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggleExpand,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}