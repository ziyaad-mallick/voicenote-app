import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.note});

  final Note note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final Note _note = widget.note;

  Future<void> _showDeleteConfirm(RetroColors c) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: c.paper,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            side: BorderSide(color: c.border, width: AppTheme.borderWidth),
          ),
          title: Text(
            'DELETE NOTE?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: c.ink,
                  letterSpacing: 1.5,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'CANCEL',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c.inkSoft,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'DELETE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c.record,
                    ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      await StorageService.instance.delete(_note.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showEditTitleDialog(RetroColors c) async {
    late TextEditingController titleController;
    late TextEditingController categoryController;

    titleController = TextEditingController(text: _note.title);
    categoryController = TextEditingController(text: _note.category);

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: c.paper,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            side: BorderSide(color: c.border, width: AppTheme.borderWidth),
          ),
          title: Text(
            'EDIT NOTE',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: c.ink,
                  letterSpacing: 1.5,
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TITLE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: c.inkSoft,
                        letterSpacing: 1,
                      ),
                ),
                SizedBox(height: AppTheme.s2),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: c.border, width: AppTheme.borderWidth),
                    ),
                    contentPadding: EdgeInsets.all(AppTheme.s2),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: c.ink,
                      ),
                ),
                SizedBox(height: AppTheme.s4),
                Text(
                  'CATEGORY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: c.inkSoft,
                        letterSpacing: 1,
                      ),
                ),
                SizedBox(height: AppTheme.s2),
                DropdownButtonFormField<String>(
                  initialValue: SettingsService.instance.categories
                          .contains(_note.category)
                      ? _note.category
                      : null,
                  items: SettingsService.instance.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat.toUpperCase(),
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: c.ink,
                                      ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      categoryController.text = value;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: c.border, width: AppTheme.borderWidth),
                    ),
                    contentPadding: EdgeInsets.all(AppTheme.s2),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'CANCEL',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c.inkSoft,
                    ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(ctx);
                _note.title = titleController.text.trim();
                _note.category = categoryController.text.trim();
                await StorageService.instance.save(_note);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
              },
              child: Text(
                'SAVE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c.accent,
                    ),
              ),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    categoryController.dispose();
  }

  String _asMarkdown() {
    final lines = <String>[
      '# ${_note.title}',
      '',
    ];
    if (_note.summary.isNotEmpty) {
      lines.addAll(['> ${_note.summary}', '']);
    }
    lines.add(_note.body);
    if (_note.tags.isNotEmpty) {
      lines.addAll(['', _note.tags.map((t) => '#$t').join(' ')]);
    }
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;

    return Scaffold(
      backgroundColor: c.paper,
      appBar: AppBar(
        backgroundColor: c.paper,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'NOTE',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: c.ink,
                letterSpacing: 2,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share, color: c.ink),
            onPressed: () {
              SharePlus.instance.share(ShareParams(text: _asMarkdown()));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: c.record),
            onPressed: () => _showDeleteConfirm(c),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.s2,
                    vertical: AppTheme.s1,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.accent, width: AppTheme.borderWidth),
                  ),
                  child: Text(
                    (_note.category.isEmpty ? 'UNCATEGORIZED' : _note.category)
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: c.accent,
                          letterSpacing: 1,
                        ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y · HH:mm').format(_note.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.inkSoft,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.s4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _note.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: c.ink,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: c.ink, size: 20),
                  onPressed: () => _showEditTitleDialog(c),
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (_note.summary.isNotEmpty) ...[
              SizedBox(height: AppTheme.s3),
              Text(
                _note.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.inkSoft,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            SizedBox(height: AppTheme.s4),
            Container(
              height: 1,
              color: c.border,
            ),
            SizedBox(height: AppTheme.s4),
            MarkdownBody(
              data: _note.body,
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.ink,
                    ),
              ),
            ),
            if (_note.tags.isNotEmpty) ...[
              SizedBox(height: AppTheme.s4),
              Wrap(
                spacing: AppTheme.s2,
                children: _note.tags
                    .map((tag) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.s2,
                            vertical: AppTheme.s1,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: c.border,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: c.inkSoft,
                                ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            if (_note.reminders.isNotEmpty) ...[
              SizedBox(height: AppTheme.s4),
              Text(
                'REMINDERS',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: c.ink,
                      letterSpacing: 1.5,
                    ),
              ),
              SizedBox(height: AppTheme.s2),
              ..._note.reminders.map((reminder) {
                final dateStr = reminder.dateTime != null
                    ? DateFormat('MMM d, y · HH:mm').format(reminder.dateTime!)
                    : 'NOW';
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.s2),
                  child: Row(
                    children: [
                      Icon(Icons.alarm, color: c.accent, size: 18),
                      SizedBox(width: AppTheme.s2),
                      Expanded(
                        child: Text(
                          '${reminder.text} — $dateStr',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: c.ink,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
