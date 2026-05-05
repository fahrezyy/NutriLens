import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Fade-in for the whole page
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Slide-up for content
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    // Pulsing glow for the icon
    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child:   const HomeScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Hero Icon ───────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Container(
                      width:  180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primary.withValues(
                                alpha: 0.25 * _pulseAnim.value),
                            AppTheme.primary.withValues(
                                alpha: 0.04 * _pulseAnim.value),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:      AppTheme.primary
                                .withValues(alpha: 0.2 * _pulseAnim.value),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size:  80,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Title ───────────────────────────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ).createShader(bounds),
                    child: Text(
                      'NutriLens',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Subtitle ────────────────────────────────────────────
                  Text(
                    'Deteksi nutrisi makananmu\nsecara instan dengan AI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:  AppTheme.onSurfaceSub,
                          height: 1.6,
                          fontSize: 16,
                        ),
                  ),

                  const SizedBox(height: 40),

                  // ── Feature pills ───────────────────────────────────────
                  Wrap(
                    spacing:    10,
                    runSpacing: 10,
                    alignment:  WrapAlignment.center,
                    children: const [
                      _FeaturePill(icon: Icons.camera_alt_rounded,
                          label: 'Foto & Deteksi'),
                      _FeaturePill(icon: Icons.bar_chart_rounded,
                          label: 'Nutrisi Lengkap'),
                      _FeaturePill(icon: Icons.auto_awesome_rounded,
                          label: 'Saran AI'),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // ── Get Started Button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Mulai Sekarang',
                              style: TextStyle(
                                  fontSize:   17,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 22),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Footer ──────────────────────────────────────────────
                  Text(
                    'Powered by YOLO & Gemini AI',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 11),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Feature pill chip ─────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String   label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color:    AppTheme.onSurfaceSub,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
