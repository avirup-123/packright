import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/trip_card.dart';
import 'trip_input_screen.dart';
import 'settings_screen.dart';

/// Home Screen
/// Displays either the empty state (no trips) or a list of trip cards
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        if (tripProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar
                _buildAppBar(context),

                // Main Content - Empty State or Trip List
                Expanded(
                  child: tripProvider.isEmpty
                      ? _buildEmptyState(context)
                      : _buildTripList(context, tripProvider),
                ),

                // New Trip Button (present in both states)
                _buildNewTripButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the top app bar with app name and settings button
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Name
          const Text(
            'PackRight',
            style: TextStyle(
              fontFamily: 'DMSerifDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          // Settings Button
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.primary,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the empty state when no trips exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Suitcase Illustration
            _buildSuitcaseIllustration(),

            const SizedBox(height: 32),

            // Heading
            const Text(
              'Where are you headed?',
              style: TextStyle(
                fontFamily: 'DMSerifDisplay',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Describe your trip and we\'ll pack for you',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a custom suitcase illustration widget
  Widget _buildSuitcaseIllustration() {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _SuitcasePainter(),
      ),
    );
  }

  /// Build the trip list when trips exist
  Widget _buildTripList(BuildContext context, TripProvider tripProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: tripProvider.trips.length,
        padding: const EdgeInsets.only(bottom: 16),
        itemBuilder: (context, index) {
          final trip = tripProvider.trips[index];
          return TripCard(
            trip: trip,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/checklist',
                arguments: trip.id,
              );
            },
            onLongPress: () {
              _showTripOptionsPopup(context, trip);
            },
          );
        },
      ),
    );
  }

  /// Show the trip options popup (Rename/Delete)
  void _showTripOptionsPopup(BuildContext context, trip) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outlined, size: 20, color: AppTheme.danger),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: AppTheme.danger)),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'rename') {
        await _showRenameDialog(context, trip);
      } else if (value == 'delete') {
        await _showDeleteConfirmation(context, trip);
      }
    });
  }

  /// Show rename dialog
  Future<void> _showRenameDialog(BuildContext context, trip) async {
    final controller = TextEditingController(text: trip.name);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Trip'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Trip Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) async {
            if (controller.text.trim().isNotEmpty) {
              await context.read<TripProvider>().renameTrip(
                    trip.id,
                    controller.text.trim(),
                  );
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await context.read<TripProvider>().renameTrip(
                      trip.id,
                      controller.text.trim(),
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(BuildContext context, trip) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip?'),
        content: const Text(
          'This can\'t be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await context.read<TripProvider>().deleteTrip(trip.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Build the "+ New Trip" button
  Widget _buildNewTripButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/trip-input');
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'New Trip',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the suitcase illustration
class _SuitcasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryLight
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.7;
    final height = size.height * 0.55;

    // Main suitcase body (rounded rectangle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: width,
        height: height,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(bodyRect, paint);
    canvas.drawRRect(bodyRect, strokePaint);

    // Handle on top
    final handlePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - height / 2 - 8),
          width: width * 0.35,
          height: 16,
        ),
        const Radius.circular(8),
      ));
    canvas.drawPath(handlePath, strokePaint);

    // Horizontal lines suggesting items inside
    final lineSpacing = height * 0.15;
    for (int i = 1; i <= 3; i++) {
      final y = center.dy - height * 0.2 + (i * lineSpacing);
      canvas.drawLine(
        Offset(center.dx - width * 0.3, y),
        Offset(center.dx + width * 0.3, y),
        strokePaint..color = AppTheme.primary.withOpacity(0.4),
      );
    }

    // Small circle (lock/buckle)
    canvas.drawCircle(
      center,
      4,
      strokePaint..color = AppTheme.primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}