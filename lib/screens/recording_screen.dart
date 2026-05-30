import 'dart:async';

import 'package:flutter/material.dart';

import '../services/formatter_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/record_button.dart';
import '../widgets/waveform.dart';
import 'note_detail_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

enum _Status { listening, processing, error }

class _RecordingScreenState extends State<RecordingScreen> {
  final SpeechService _speech = SpeechService();
  String _transcript = '';
  double _level = 0;
  int _elapsed = 0;
  Timer? _timer;
  _Status _status = _Status.listening;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _begin();
  }

  Future<void> _begin() async {
    final ok = await _speech.init();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _status = _Status.error;
        _errorMessage = 'Microphone initialization failed.';
      });
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed++);
      }
    });

    await _speech.start(
      onPartial: (t) {
        if (mounted) {
          setState(() => _transcript = t);
        }
      },
      onLevel: (l) {
        if (mounted) {
          setState(() => _level = l);
        }
      },
    );

    if (mounted) {
      setState(() => _status = _Status.listening);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final text = await _speech.stop();

    if (!mounted) return;

    if (text.trim().isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing captured')),
      );
      return;
    }

    setState(() => _status = _Status.processing);

    final note = await FormatterService.format(
      text,
      categories: SettingsService.instance.categories,
      apiKey: SettingsService.instance.apiKey,
    );
    await StorageService.instance.save(note);

    for (final r in note.reminders) {
      await NotificationService.instance.scheduleReminder(r, note.title);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(note: note),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_speech.isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  String _formatElapsed() {
    final minutes = _elapsed ~/ 60;
    final seconds = _elapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;

    return Scaffold(
      backgroundColor: c.paper,
      body: _buildByStatus(c),
    );
  }

  Widget _buildByStatus(RetroColors c) {
    switch (_status) {
      case _Status.listening:
        return _buildListening(c);
      case _Status.processing:
        return _buildProcessing(c);
      case _Status.error:
        return _buildError(c);
    }
  }

  Widget _buildListening(RetroColors c) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatElapsed(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFamily: 'monospace',
                        color: c.ink,
                      ),
                ),
                SizedBox(height: AppTheme.s5),
                Waveform(level: _level, color: c.accent),
                SizedBox(height: AppTheme.s5),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(AppTheme.s4),
              padding: EdgeInsets.all(AppTheme.s4),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.all(color: c.border, width: AppTheme.borderWidth),
              ),
              child: SingleChildScrollView(
                child: _transcript.isEmpty
                    ? Text(
                        'LISTENING…',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: c.inkSoft,
                              fontStyle: FontStyle.italic,
                            ),
                      )
                    : Text(
                        _transcript,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: c.ink,
                                ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.s4),
            child: Column(
              children: [
                RecordButton(
                  isRecording: true,
                  onTap: _stop,
                  size: 72,
                ),
                SizedBox(height: AppTheme.s3),
                Text(
                  'TAP TO STOP',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: c.ink,
                        letterSpacing: 2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing(RetroColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'FORMATTING…',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: c.ink,
                  letterSpacing: 3,
                ),
          ),
          SizedBox(height: AppTheme.s5),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(c.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildError(RetroColors c) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.s5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MIC UNAVAILABLE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: c.ink,
                    letterSpacing: 2,
                  ),
            ),
            SizedBox(height: AppTheme.s4),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'VoiceNote needs microphone & speech permission. Enable it in settings and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.inkSoft,
                  ),
            ),
            SizedBox(height: AppTheme.s5),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.border, width: AppTheme.borderWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.s5,
                  vertical: AppTheme.s3,
                ),
              ),
              child: Text(
                'GO BACK',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c.ink,
                      letterSpacing: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
