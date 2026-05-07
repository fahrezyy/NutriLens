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

          // ── Gemini API Key ────────────────────────────────────────────────
          _ApiKeyField(
            value:     settings.geminiApiKey,
            onChanged: (v) => settings.geminiApiKey = v,
          ),
          const SizedBox(height: 20),

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

// ═══════════════════════════════════════════════════════════════════════════
// Threshold Slider — tappable badge opens a dialog for precise % input
// ═══════════════════════════════════════════════════════════════════════════
class _ThresholdSlider extends StatelessWidget {
  final String               label;
  final IconData             icon;
  final double               value;
  final ValueChanged<double> onChanged;
  final String               subtitle;

  const _ThresholdSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.subtitle,
  });

  void _showInputDialog(BuildContext context) {
    final pct = value * 100;
    final controller = TextEditingController(
      text: pct % 1 == 0 ? '${pct.toInt()}' : pct.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, color: AppTheme.onSurface)),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            suffixText: '%',
            suffixStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary.withValues(alpha: 0.7),
            ),
            hintText: '0 - 100',
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppTheme.onSurfaceSub.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
          onSubmitted: (text) {
            _applyValue(text);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.onSurfaceSub)),
          ),
          ElevatedButton(
            onPressed: () {
              _applyValue(controller.text);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _applyValue(String text) {
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed != null) {
      // User types percentage (e.g. 0.5 means 0.5%)
      onChanged((parsed / 100).clamp(0.0, 1.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = value * 100;
    final displayText =
        pct % 1 == 0 ? '${pct.toInt()}%' : '${pct.toStringAsFixed(1)}%';

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
            GestureDetector(
              onTap: () => _showInputDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayText,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_rounded,
                        size: 12,
                        color: AppTheme.primary.withValues(alpha: 0.7)),
                  ],
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
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: AppTheme.surfaceCard2,
            thumbColor: AppTheme.primary,
            overlayColor: AppTheme.primary.withValues(alpha: 0.15),
            trackHeight: 4,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// API Key Field
// ═══════════════════════════════════════════════════════════════════════════
class _ApiKeyField extends StatefulWidget {
  final String               value;
  final ValueChanged<String> onChanged;

  const _ApiKeyField({required this.value, required this.onChanged});

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  late TextEditingController _ctrl;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ApiKeyField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasKey = widget.value.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.key_rounded, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Google AI API Key',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: hasKey
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : AppTheme.onSurfaceSub.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hasKey ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  color:    hasKey ? AppTheme.primary : AppTheme.onSurfaceSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Masukkan API key untuk mengaktifkan saran AI gizi',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          obscureText: _obscured,
          style: const TextStyle(fontSize: 13, color: AppTheme.onSurface),
          decoration: InputDecoration(
            hintText: 'AIzaSy...',
            hintStyle: TextStyle(
                color: AppTheme.onSurfaceSub.withValues(alpha: 0.5),
                fontSize: 13),
            filled:    true,
            fillColor: AppTheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: AppTheme.onSurfaceSub,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
