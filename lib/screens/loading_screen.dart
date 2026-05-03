import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../models/trip.dart';

/// Loading Screen
/// Shows while AI generates the packing list from the trip description
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  String? _tripId;
  String? _description;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentMessageIndex = 0;
  double _pulseValue = 1.0;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const List<String> _statusMessages = [
    'Checking the weather at your destination...',
    'Thinking about what you\'ll need...',
    'Organizing by category...',
    'Almost done...',
  ];

  bool _didStart = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStart) {
      _didStart = true;
      _startLoading();
    }
  }

  void _setupAnimations() {
    // Pulsing animation for the circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _pulseController.forward();
        }
      });

    _pulseController.addListener(() {
      setState(() {
        _pulseValue = 1.0 + (_pulseController.value * 0.05);
      });
    });

    // Fade animation for text transitions
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _pulseController.forward();
    _fadeController.forward();

    // Set up text rotation timer
    _startTextRotation();
  }

  void _startTextRotation() {
    // Change text every 2.5 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted || !_isLoading) return false;

      // Fade out
      await _fadeController.reverse();
      if (!mounted) return false;

      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % _statusMessages.length;
      });

      // Fade in
      await _fadeController.forward();
      return _isLoading;
    });
  }

  Future<void> _startLoading() async {
    // Get trip ID and description from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    setState(() {
      _tripId = args?['tripId'] as String?;
      _description = args?['description'] as String?;
    });

    // Start the AI generation
    await _generatePackingList();
  }

  Future<void> _generatePackingList() async {
    if (_description == null || _tripId == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Missing trip information.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Call AI service to generate packing list
      final categories = await AIService.generatePackingList(_description!);

      if (!mounted) return;

      // Find the trip and update it with the generated categories
      final provider = context.read<TripProvider>();
      final trip = provider.getTripById(_tripId!);

      if (trip != null) {
        final updatedTrip = trip.copyWith(
          categories: categories,
          updatedAt: DateTime.now(),
        );
        await provider.updateTrip(updatedTrip);
      }

      // Navigate to checklist screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/checklist',
          arguments: _tripId,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e is Exception ? e.toString().replaceAll('ApiException: ', '') : 'An unexpected error occurred.';
      });

      // Stop animations on error
      _pulseController.stop();
      _fadeController.stop();
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _currentMessageIndex = 0;
    });

    // Restart animations
    _pulseController.reset();
    _pulseController.forward();
    _fadeController.reset();
    _fadeController.forward();
    _startTextRotation();

    // Retry generation
    _generatePackingList();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        // Navigate back to trip input, preserving state
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading && !_hasError) ...[
                    // Animated pulsing circle with suitcase icon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseValue,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.luggage,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Rotating status text with fade transition
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _statusMessages[_currentMessageIndex],
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else if (_hasError) ...[
                    // Error state
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.danger,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Couldn\'t generate your list',
                      style: TextStyle(
                        fontFamily: 'DMSerifDisplay',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _errorMessage ?? 'Check your internet connection and try again.',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Try Again button
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}