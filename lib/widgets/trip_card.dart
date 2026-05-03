import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';

/// Trip Card Widget
/// Displays a single trip with name, description preview, date, and progress
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onLongPress,
  });

  /// Generate a consistent color from the trip name
  Color _getColorFromName(String name) {
    // List of preset colors to choose from
    final colors = [
      const Color(0xFF1B7A6E), // Primary teal
      const Color(0xFF2196F3), // Blue
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFFFF5722), // Deep orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue grey
      const Color(0xFF4CAF50), // Green
    ];

    // Hash the name to get a consistent index
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getColorFromName(trip.name);
    final isComplete = trip.totalItems > 0 && trip.completionPercentage >= 1.0;
    final progressColor = isComplete ? AppTheme.success : AppTheme.accent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Colored dot indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 16),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip name
                    Text(
                      trip.name,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description preview
                    Text(
                      trip.descriptionPreview,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Creation date
                    Text(
                      trip.formattedCreatedAt,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Progress indicator
              _buildProgressRing(accentColor, progressColor, isComplete),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the circular progress indicator
  Widget _buildProgressRing(Color accentColor, Color progressColor, bool isComplete) {
    if (trip.totalItems == 0) {
      // No items yet - show a dash
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Text(
            '–',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: trip.completionPercentage,
              strokeWidth: 3.5,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          // Progress text (e.g., "17/34")
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${trip.packedItems}',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
              Text(
                '/${trip.totalItems}',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}