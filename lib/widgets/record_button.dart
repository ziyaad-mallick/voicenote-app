import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final double size;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.size = 96,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseFade;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseScale = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseFade = Tween<double>(begin: 0.8, end: 0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    if (widget.isRecording) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;

    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isRecording)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseScale.value,
                      child: Opacity(
                        opacity: _pulseFade.value,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c.record,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.paper,
                  border: Border.all(
                    color: c.ink,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: widget.isRecording ? 28 : 24,
                    height: widget.isRecording ? 28 : 24,
                    decoration: BoxDecoration(
                      color: c.record,
                      borderRadius: widget.isRecording
                          ? BorderRadius.circular(6)
                          : BorderRadius.zero,
                      shape: widget.isRecording
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
