import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  String _formatRelativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) {
      return 'JUST NOW';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}M AGO';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}H AGO';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}D AGO';
    } else {
      return DateFormat('MMM d').format(createdAt).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;
    final relativeTime = _formatRelativeTime(note.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.s3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.s4),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(
              color: c.border,
              width: AppTheme.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.category.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: c.accent,
                          letterSpacing: 1.5,
                        ),
                  ),
                  Text(
                    relativeTime,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: c.inkSoft,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s2),
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: c.ink,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.s2),
              Text(
                note.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.inkSoft,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
