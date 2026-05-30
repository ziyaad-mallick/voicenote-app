import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/note_card.dart';
import '../widgets/record_button.dart';
import 'recording_screen.dart';
import 'note_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _notes = StorageService.instance.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;

    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        backgroundColor: c.paper,
        elevation: 0,
        title: Text(
          'VOICENOTE',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: c.ink,
                letterSpacing: 2,
              ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: c.ink),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
              if (!mounted) return;
              await _refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _notes.isEmpty
                ? _buildEmptyState(c)
                : _buildNotesList(c),
          ),
          _buildRecordBar(c),
        ],
      ),
    );
  }

  Widget _buildEmptyState(RetroColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NO NOTES YET',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: c.inkSoft,
                  letterSpacing: 2,
                ),
          ),
          SizedBox(height: AppTheme.s3),
          Text(
            'Tap record to capture your first note.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.inkSoft,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(RetroColors c) {
    return ListView.builder(
      padding: EdgeInsets.all(AppTheme.s4),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return NoteCard(
          note: note,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteDetailScreen(note: note),
              ),
            );
            if (!mounted) return;
            await _refresh();
          },
        );
      },
    );
  }

  Widget _buildRecordBar(RetroColors c) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.s5),
        child: Column(
          children: [
            RecordButton(
              isRecording: false,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecordingScreen(),
                  ),
                );
                if (!mounted) return;
                await _refresh();
              },
            ),
            SizedBox(height: AppTheme.s2),
            Text(
              'TAP TO RECORD',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.inkSoft,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
