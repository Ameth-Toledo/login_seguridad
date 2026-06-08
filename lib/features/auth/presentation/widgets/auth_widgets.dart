// Re-exporta los widgets compartidos con alias específicos de auth
// para respetar la arquitectura (features/auth/presentation/widgets/).
export '../../../../shared/widgets/custom_button.dart' show CustomButton;
export '../../../../shared/widgets/custom_text_field.dart'
    show CustomTextField;

// Widget específico de auth: indicador del timer de inactividad
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class InactivityTimerBadge extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const InactivityTimerBadge({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  Color get _color {
    final ratio = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0;
    if (ratio > 0.5) return AppColors.timerGreen;
    if (ratio > 0.2) return AppColors.timerYellow;
    return AppColors.timerRed;
  }

  String get _label {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 14, color: _color),
        const SizedBox(width: 4),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}