import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/nutrilens_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../core/theme.dart';
import 'widgets/bounding_box_overlay.dart';
import 'widgets/nutrient_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm       = context.watch<NutriLensViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final result   = vm.result!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsing image header ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned:          true,
            backgroundColor: AppTheme.surface,
            leading: IconButton(
              onPressed: () {
                vm.reset();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  vm.reset();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.camera_alt_rounded,
                    color: AppTheme.primary),
                tooltip: 'Foto ulang',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: vm.capturedImage != null
                  ? BoundingBoxOverlay(
                      imageFile:  vm.capturedImage!,
                      detections: result.detections,
                      boxOpacity: settings.opacityThreshold,
                    )
                  : const SizedBox(),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Detected foods chips
                _SectionTitle(title: 'Makanan Terdeteksi',
                    icon: Icons.food_bank_rounded),
                const SizedBox(height: 12),
                if (result.foodCounts.isEmpty)
                  const _EmptyState()
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result.foodCounts.entries.map((e) {
                      return _FoodChip(name: e.key, count: e.value);
                    }).toList(),
                  ),

                const SizedBox(height: 28),

                // Nutrition totals
                _SectionTitle(title: 'Total Nutrisi',
                    icon: Icons.bar_chart_rounded),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap:     true,
                  physics:        const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing:  12,
                  childAspectRatio: 1.5,
                  children: [
                    NutrientCard(
                      label:  'Kalori',
                      value:  '${result.totalCalories.toStringAsFixed(0)} kkal',
                      icon:   Icons.local_fire_department_rounded,
                      color:  AppTheme.calorieColor,
                    ),
                    NutrientCard(
                      label:  'Protein',
                      value:  '${result.totalProtein.toStringAsFixed(1)} g',
                      icon:   Icons.fitness_center_rounded,
                      color:  AppTheme.proteinColor,
                    ),
                    NutrientCard(
                      label:  'Lemak',
                      value:  '${result.totalFat.toStringAsFixed(1)} g',
                      icon:   Icons.water_drop_rounded,
                      color:  AppTheme.fatColor,
                    ),
                    NutrientCard(
                      label:  'Karbohi\u00addrat',
                      value:  '${result.totalCarbs.toStringAsFixed(1)} g',
                      icon:   Icons.grain_rounded,
                      color:  AppTheme.carbColor,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Per-food breakdown
                if (result.resolvedFoods.isNotEmpty) ...[
                  _SectionTitle(title: 'Rincian per Makanan',
                      icon: Icons.list_alt_rounded),
                  const SizedBox(height: 12),
                  ...result.resolvedFoods.map(
                    (f) => _FoodDetailRow(food: f),
                  ),
                  const SizedBox(height: 28),
                ],

                // Gemini advice
                _SectionTitle(title: 'Saran AI Gizi',
                    icon: Icons.psychology_rounded),
                const SizedBox(height: 12),
                _GeminiCard(text: result.geminiAnalysis),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

// ── Food chip ─────────────────────────────────────────────────────────────
class _FoodChip extends StatelessWidget {
  final String name;
  final int    count;
  const _FoodChip({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.18),
            AppTheme.primaryDark.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _capitalize(name),
            style: const TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.w600),
          ),
          if (count > 1) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text('×$count',
                  style: const TextStyle(
                      color: AppTheme.surface,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Per-food detail row ───────────────────────────────────────────────────
class _FoodDetailRow extends StatelessWidget {
  final dynamic food; // FoodItem
  const _FoodDetailRow({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _capitalize(food.name as String),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          _MiniStat('${(food.calories as double).toStringAsFixed(0)}', 'kkal',
              AppTheme.calorieColor),
          const SizedBox(width: 12),
          _MiniStat('${(food.proteins as double).toStringAsFixed(1)}', 'P',
              AppTheme.proteinColor),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String unit;
  final Color  color;
  const _MiniStat(this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
          TextSpan(
            text: ' $unit',
            style: const TextStyle(
                color: AppTheme.onSurfaceSub, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Gemini advice card ────────────────────────────────────────────────────
class _GeminiCard extends StatelessWidget {
  final String text;
  const _GeminiCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.12),
            AppTheme.primaryDark.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Gemini AI',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  color: AppTheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tidak ada makanan terdeteksi',
          style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
