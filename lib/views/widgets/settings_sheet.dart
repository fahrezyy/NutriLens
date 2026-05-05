import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context:           context,
      backgroundColor:   Colors.transparent,
      isScrollControlled: true,
      builder:           (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.onSurfaceSub,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Pengaturan Deteksi',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () => settings.resetDefaults(),
                child: const Text('Reset',
                    style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Confidence Threshold ──────────────────────────────────────────
          _ThresholdSlider(
            label:     'Confidence Threshold',
            icon:      Icons.psychology_rounded,
            value:     settings.confidenceThreshold,
            onChanged: (v) => settings.confidenceThreshold = v,
            subtitle:  'Tingkat keyakinan minimum deteksi makanan',
          ),
          const SizedBox(height: 20),

          // ── Overlap Threshold ─────────────────────────────────────────────
          _ThresholdSlider(
            label:     'Overlap Threshold',
            icon:      Icons.layers_rounded,
            value:     settings.overlapThreshold,
            onChanged: (v) => settings.overlapThreshold = v,
            subtitle:  'Ambang batas tumpang tindih bounding box (IoU)',
          ),
          const SizedBox(height: 20),

          // ── Opacity Threshold ─────────────────────────────────────────────
          _ThresholdSlider(
            label:     'Opacity Threshold',
            icon:      Icons.opacity_rounded,
            value:     settings.opacityThreshold,
            onChanged: (v) => settings.opacityThreshold = v,
            subtitle:  'Tingkat transparansi overlay bounding box',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ThresholdSlider extends StatelessWidget {
  final String          label;
  final IconData        icon;
  final double          value;
  final ValueChanged<double> onChanged;
  final String          subtitle;

  const _ThresholdSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  color:      AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize:   13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 12)),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor:   AppTheme.primary,
            inactiveTrackColor: AppTheme.surfaceCard2,
            thumbColor:         AppTheme.primary,
            overlayColor:       AppTheme.primary.withValues(alpha: 0.15),
            trackHeight:        4,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value:    value,
            min:      0.0,
            max:      1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
