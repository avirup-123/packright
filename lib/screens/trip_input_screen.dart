import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../models/trip.dart';

/// Trip Input Screen
/// Where users describe their trip in natural language to generate a packing list
/// Supports both create mode (new trip) and edit mode (regenerate existing trip)
class TripInputScreen extends StatefulWidget {
  const TripInputScreen({super.key});

  @override
  State<TripInputScreen> createState() => _TripInputScreenState();
}

class _TripInputScreenState extends State<TripInputScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isButtonActive = false;
  static const int _minCharacters = 15;

  // Edit mode fields
  bool _isEditMode = false;
  String? _editTripId;

  bool _didInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _checkForEditMode();
      _initializeControllers();
      _setupDescriptionListener();
    }
  }

  void _checkForEditMode() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args['isEdit'] == true) {
        _isEditMode = true;
        _editTripId = args['tripId'] as String?;
      }
    }
  }

  void _initializeControllers() {
    String initialName;
    String initialDescription;

    if (_isEditMode) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      initialName = args?['tripName'] as String? ?? 'Edit Trip';
      initialDescription = args?['description'] as String? ?? '';
    } else {
      // Generate default trip name with current month and year
      final now = DateTime.now();
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      initialName = 'Trip — ${months[now.month - 1]} ${now.year}';
      initialDescription = '';
    }

    _nameController = TextEditingController(text: initialName);
    _descriptionController = TextEditingController(text: initialDescription);
  }

  void _setupDescriptionListener() {
    _descriptionController.addListener(() {
      final isActive = _descriptionController.text.length >= _minCharacters;
      if (isActive != _isButtonActive) {
        setState(() {
          _isButtonActive = isActive;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generatePackingList() async {
    if (!_isButtonActive) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.length < _minCharacters) return;

    if (_isEditMode && _editTripId != null) {
      // Edit mode: update existing trip
      final provider = context.read<TripProvider>();
      final existingTrip = provider.getTripById(_editTripId!);

      if (existingTrip == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip not found')),
          );
        }
        return;
      }

      // Update trip with new name and description, clear old categories
      final updatedTrip = existingTrip.copyWith(
        name: name,
        description: description,
        categories: [], // Clear old categories, will be populated by AI
      );

      await provider.updateTrip(updatedTrip);

      if (!mounted) return;

      // Navigate to loading screen
      Navigator.pushReplacementNamed(
        context,
        '/loading',
        arguments: {
          'tripId': _editTripId,
          'description': description,
          'isRegenerating': true,
        },
      );
    } else {
      // Create mode: create new trip
      final trip = Trip(
        name: name,
        description: description,
        categories: [], // Will be populated by AI
      );

      // Save the trip via provider
      await context.read<TripProvider>().addTrip(trip);

      if (!mounted) return;

      // Navigate to loading screen with trip ID
      Navigator.pushReplacementNamed(
        context,
        '/loading',
        arguments: {'tripId': trip.id, 'description': description},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with back arrow and title
              _buildTopBar(),

              const SizedBox(height: 24),

              // Trip Name Field
              _buildTripNameField(),

              const SizedBox(height: 20),

              // Main Description Text Area
              _buildDescriptionArea(),

              const SizedBox(height: 8),

              // Helper Text
              _buildHelperText(),

              const SizedBox(height: 32),

              // Generate Button
              _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _isEditMode ? 'Edit Trip' : 'New Trip',
          style: const TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTripNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip name',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryLight,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionArea() {
    return Stack(
      children: [
        TextField(
          controller: _descriptionController,
          maxLines: 8,
          minLines: 6,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.textPrimaryLight,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardLight,
            hintText: _isEditMode
                ? 'Edit your trip description...'
                : 'Describe your trip — where are you going, for how long, what will you be doing?\n\ne.g. 5 days in Manali, January, trekking in snow, staying in a hostel',
            hintStyle: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        // Microphone icon in bottom-right corner
        Positioned(
          right: 8,
          bottom: 8,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mic,
                size: 20,
                color: AppTheme.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Focus node for the description field
  final FocusNode _descriptionFocusNode = FocusNode();

  Widget _buildHelperText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        _isEditMode
            ? 'Modify your trip description to regenerate the packing list'
            : 'The more detail you give, the better your list will be',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _descriptionController,
      builder: (context, value, child) {
        final isActive = value.text.length >= _minCharacters;

        return Opacity(
          opacity: isActive ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !isActive,
            child: ElevatedButton.icon(
              onPressed: isActive ? _generatePackingList : null,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: Text(
                _isEditMode
                    ? 'Regenerate Packing List'
                    : 'Generate My Packing List',
                style: const TextStyle(
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
      },
    );
  }
}