import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Waveform extends StatefulWidget {
  final double level;
  final Color? color;

  const Waveform({
    super.key,
    required this.level,
    this.color,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  static const int _bufferSize = 40;
  final List<double> _levels = [];

  @override
  void didUpdateWidget(Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level != oldWidget.level) {
      final normalized = (widget.level / 10).clamp(0.02, 1.0);
      _levels.add(normalized);
      if (_levels.length > _bufferSize) {
        _levels.removeAt(0);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;
    final barColor = widget.color ?? c.accent;

    return SizedBox(
      height: 64,
      child: CustomPaint(
        painter: _WaveformPainter(
          levels: _levels,
          color: barColor,
          borderColor: c.border,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> levels;
  final Color color;
  final Color borderColor;

  _WaveformPainter({
    required this.levels,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.0;
    const barSpacing = 2.0;
    final centerY = size.height / 2;
    final maxBarHeight = size.height * 0.8;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppTheme.borderWidth;

    final barCount = ((size.width) / (barWidth + barSpacing)).floor();

    if (levels.isEmpty) {
      final x = (size.width - barWidth) / 2;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: barWidth,
          height: 2,
        ),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: barWidth,
          height: 2,
        ),
        borderPaint,
      );
      return;
    }

    final startIndex = (levels.length > barCount)
        ? levels.length - barCount
        : 0;

    for (int i = 0; i < barCount; i++) {
      final levelIndex = startIndex + i;
      final level = levelIndex < levels.length ? levels[levelIndex] : 0.02;
      final barHeight = maxBarHeight * level;
      final x = i * (barWidth + barSpacing) + barSpacing / 2;

      final rect = Rect.fromCenter(
        center: Offset(x + barWidth / 2, centerY),
        width: barWidth,
        height: barHeight,
      );

      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.levels != levels ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}
