import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onThemeChanged});

  final VoidCallback? onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _userEmailController;
  late TextEditingController _apiKeyController;
  late List<TextEditingController> _categoryControllers;

  @override
  void initState() {
    super.initState();
    _userNameController =
        TextEditingController(text: SettingsService.instance.userName);
    _userEmailController =
        TextEditingController(text: SettingsService.instance.userEmail);
    _apiKeyController =
        TextEditingController(text: SettingsService.instance.apiKey);
    _categoryControllers = SettingsService.instance.categories
        .map((cat) => TextEditingController(text: cat))
        .toList();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _apiKeyController.dispose();
    for (final controller in _categoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateCategories() {
    final newCategories = _categoryControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    SettingsService.instance.categories = newCategories;
  }

  void _addCategory() {
    setState(() {
      _categoryControllers.add(TextEditingController());
    });
  }

  void _removeCategory(int index) {
    setState(() {
      _categoryControllers[index].dispose();
      _categoryControllers.removeAt(index);
    });
    _updateCategories();
  }

  Widget _section(String title, RetroColors c) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppTheme.s5,
        bottom: AppTheme.s3,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: c.inkSoft,
              letterSpacing: 2,
            ),
      ),
    );
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
          'SETTINGS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: c.ink,
                letterSpacing: 2,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('PROFILE', c),
            TextField(
              controller: _userNameController,
              onChanged: (value) {
                SettingsService.instance.userName = value;
              },
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.inkSoft,
                    ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: c.border, width: AppTheme.borderWidth),
                ),
                contentPadding: EdgeInsets.all(AppTheme.s3),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.ink,
                  ),
            ),
            SizedBox(height: AppTheme.s3),
            TextField(
              controller: _userEmailController,
              onChanged: (value) {
                SettingsService.instance.userEmail = value;
              },
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.inkSoft,
                    ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: c.border, width: AppTheme.borderWidth),
                ),
                contentPadding: EdgeInsets.all(AppTheme.s3),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.ink,
                  ),
            ),
            _section('CATEGORIES', c),
            ..._categoryControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.s3),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (_) => _updateCategories(),
                        decoration: InputDecoration(
                          hintText: 'Category name',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: c.inkSoft,
                              ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: c.border,
                              width: AppTheme.borderWidth,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(AppTheme.s3),
                        ),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: c.ink,
                                ),
                      ),
                    ),
                    SizedBox(width: AppTheme.s2),
                    IconButton(
                      icon: Icon(Icons.close, color: c.record, size: 20),
                      onPressed: () => _removeCategory(index),
                      constraints: BoxConstraints.tight(const Size(40, 40)),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: AppTheme.s2),
            OutlinedButton(
              onPressed: _addCategory,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.border, width: AppTheme.borderWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.s4,
                  vertical: AppTheme.s2,
                ),
              ),
              child: Text(
                '+ ADD CATEGORY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c.ink,
                      letterSpacing: 1,
                    ),
              ),
            ),
            _section('SMART FORMATTING', c),
            TextField(
              controller: _apiKeyController,
              onChanged: (value) {
                SettingsService.instance.apiKey = value;
                setState(() {});
              },
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'API key (optional)',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.inkSoft,
                    ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: c.border, width: AppTheme.borderWidth),
                ),
                contentPadding: EdgeInsets.all(AppTheme.s3),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.ink,
                  ),
            ),
            SizedBox(height: AppTheme.s3),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _apiKeyController.text.trim().isNotEmpty
                        ? c.accent
                        : c.inkSoft,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppTheme.s2),
                Text(
                  _apiKeyController.text.trim().isNotEmpty
                      ? 'AI FORMATTING: ON'
                      : 'RULE-BASED (OFFLINE)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _apiKeyController.text.trim().isNotEmpty
                            ? c.accent
                            : c.inkSoft,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.s3),
            Text(
              'Free key: console.groq.com',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c.inkSoft,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            _section('APPEARANCE', c),
            Wrap(
              spacing: AppTheme.s2,
              children: ['SYSTEM', 'LIGHT', 'DARK'].map((mode) {
                final isSelected =
                    SettingsService.instance.themeModeName == mode;
                return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      SettingsService.instance.themeModeName = mode;
                    });
                    widget.onThemeChanged?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? c.accent : Colors.transparent,
                    side: BorderSide(
                      color: isSelected ? c.accent : c.border,
                      width: AppTheme.borderWidth,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.s3,
                      vertical: AppTheme.s2,
                    ),
                  ),
                  child: Text(
                    mode,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected ? c.paper : c.ink,
                          letterSpacing: 1,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
