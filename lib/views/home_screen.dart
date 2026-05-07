import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/nutrilens_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../core/theme.dart';
import 'result_screen.dart';
import 'widgets/settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutriLensViewModel>();

    // Navigate to result when done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.state == AnalysisState.done && vm.result != null) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: const ResultScreen(),
            ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(vm)),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: AppTheme.surface, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NutriLens',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppTheme.primary)),
              Text('Deteksi nutrisi makananmu',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Spacer(),
          // ── Settings button ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () => SettingsSheet.show(context),
              icon: const Icon(Icons.tune_rounded,
                  color: AppTheme.primary, size: 22),
              tooltip: 'Pengaturan',
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody(NutriLensViewModel vm) {
    if (vm.isProcessing) {
      return _buildProcessingState(vm);
    }
    if (vm.state == AnalysisState.error) {
      return _buildErrorState(vm);
    }
    return _buildIdleState();
  }

  Widget _buildIdleState() {
    final settings = context.read<SettingsViewModel>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.15),
                AppTheme.primary.withValues(alpha: 0.03),
              ],
            ),
          ),
          child: Icon(Icons.fastfood_rounded,
              size: 80, color: AppTheme.primary.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 28),
        Text(
          'Foto Makananmu',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Arahkan kamera ke piringmu atau pilih\nfoto dari galeri untuk menghitung nutrisinya 🍽️',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),

        // Camera button
        _CameraButton(
          pulseAnim: _pulseAnim,
          onTap: () {
            context.read<NutriLensViewModel>().captureAndAnalyze(
              confidenceThreshold: settings.confidenceThreshold,
              overlapThreshold:    settings.overlapThreshold,
              geminiApiKey:        settings.geminiApiKey,
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          'Ketuk untuk membuka kamera',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 24),

        // ── Gallery button ────────────────────────────────────────────────
        _GalleryButton(
          onTap: () {
            context.read<NutriLensViewModel>().pickFromGalleryAndAnalyze(
              confidenceThreshold: settings.confidenceThreshold,
              overlapThreshold:    settings.overlapThreshold,
              geminiApiKey:        settings.geminiApiKey,
            );
          },
        ),
      ],
    );
  }

  Widget _buildProcessingState(NutriLensViewModel vm) {
    final steps = [
      (AnalysisState.detecting,       '🔍', 'Mendeteksi makanan'),
      (AnalysisState.fetchingNutrition,'📊', 'Menghitung nutrisi'),
      (AnalysisState.generatingAdvice, '🤖', 'Meminta saran AI'),
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Memproses…',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          ...steps.map((step) {
            final isActive  = vm.state == step.$1;
            final isDone    = _stateIndex(vm.state) > _stateIndex(step.$1);
            return _StepRow(
              emoji:    step.$2,
              label:    step.$3,
              isActive: isActive,
              isDone:   isDone,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorState(NutriLensViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.error, size: 72),
          const SizedBox(height: 24),
          Text('Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
            ),
            child: Text(
              vm.errorMessage ?? 'Unknown error',
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<NutriLensViewModel>().reset(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Text(
        'Powered by YOLO & Gemini AI',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontSize: 11),
      ),
    );
  }

  int _stateIndex(AnalysisState s) {
    const order = [
      AnalysisState.idle,
      AnalysisState.detecting,
      AnalysisState.fetchingNutrition,
      AnalysisState.generatingAdvice,
      AnalysisState.done,
      AnalysisState.error,
    ];
    return order.indexOf(s);
  }
}

// ── Camera Button Widget ──────────────────────────────────────────────────
class _CameraButton extends StatelessWidget {
  final Animation<double> pulseAnim;
  final VoidCallback      onTap;
  const _CameraButton({required this.pulseAnim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnim,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape:     BoxShape.circle,
            gradient:  const LinearGradient(
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color:       AppTheme.primary.withValues(alpha: 0.5),
                blurRadius:  24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt_rounded,
              color: AppTheme.surface, size: 36),
        ),
      ),
    );
  }
}

// ── Gallery Button Widget ─────────────────────────────────────────────────
class _GalleryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_rounded,
                color: AppTheme.primary.withValues(alpha: 0.9), size: 20),
            const SizedBox(width: 10),
            const Text(
              'Pilih dari Galeri',
              style: TextStyle(
                color:      AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize:   14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step Row Widget ───────────────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final String emoji;
  final String label;
  final bool   isActive;
  final bool   isDone;

  const _StepRow({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppTheme.primary
        : isActive
            ? AppTheme.onSurface
            : AppTheme.onSurfaceSub;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color:      color,
              fontSize:   16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          if (isDone) const Icon(Icons.check_circle_rounded,
              color: AppTheme.primary, size: 18),
          if (isActive)
            const SizedBox(
              width:  14,
              height: 14,
              child:  CircularProgressIndicator(
                strokeWidth: 2,
                color:       AppTheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
