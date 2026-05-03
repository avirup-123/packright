import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<_ConfettiPiece> _confetti = [];

  // AdMob
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  static const String _bannerAdUnitId = 'ca-app-pub-6126724629064811/9519251651';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Generate confetti
    final seed = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 40; i++) {
      _confetti.add(_ConfettiPiece(
        x: (seed + i * 137) % 1000 / 1000,
        delay: i * 60,
        color: [
          AppTheme.primary,
          AppTheme.accent,
          AppTheme.success,
          const Color(0xFFE74C8B),
          const Color(0xFF9B59B6),
          const Color(0xFF3498DB),
        ][(seed + i) % 6],
        size: 6.0 + ((seed + i * 31) % 6),
      ));
    }

    // Stagger animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _confettiController.forward();
    });

    // Load banner ad (Android/iOS only)
    if (!kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _isBannerAdReady = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: (!kIsWeb && _isBannerAdReady && _bannerAd != null)
          ? SafeArea(
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Confetti layer
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return Stack(
                children: _confetti.map((piece) {
                  final progress = _confettiController.value;
                  final adjusted = (progress * 3000 - piece.delay) / 2500;
                  if (adjusted < 0 || adjusted > 1) return const SizedBox.shrink();
                  final y = adjusted * MediaQuery.of(context).size.height;
                  final opacity = adjusted > 0.75 ? (1 - adjusted) * 4 : 1.0;
                  return Positioned(
                    left: piece.x * MediaQuery.of(context).size.width,
                    top: y,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: adjusted * 6.28 * piece.x,
                        child: Container(
                          width: piece.size,
                          height: piece.size,
                          decoration: BoxDecoration(
                            color: piece.color,
                            borderRadius: BorderRadius.circular(piece.size * 0.2),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🎉',
                            style: TextStyle(fontSize: 56),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Headline
                    const Text(
                      'Congratulations,',
                      style: TextStyle(
                        fontFamily: 'DMSerifDisplay',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.primary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      "You're All Set!",
                      style: TextStyle(
                        fontFamily: 'DMSerifDisplay',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textPrimaryLight,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Subtext
                    Text(
                      'Your bags are packed and you\'re ready to go.\nHave an amazing trip! ✈️',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Divider with icon
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.primary.withOpacity(0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.luggage_outlined,
                            color: AppTheme.primary.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.primary.withOpacity(0.2))),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Back to home button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Back to checklist button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Checklist',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final int delay;
  final Color color;
  final double size;
  _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.color,
    required this.size,
  });
}
