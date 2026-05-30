import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/settings_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentStep = 0;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late List<TextEditingController> _categoryControllers;
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _apiKeyController = TextEditingController();
    _categoryControllers = [
      TextEditingController(text: 'Projects'),
      TextEditingController(text: 'Ideas'),
      TextEditingController(text: 'Uni'),
      TextEditingController(text: 'Personal'),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _apiKeyController.dispose();
    for (final controller in _categoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    final settings = SettingsService.instance;
    settings.userName = _nameController.text.trim();
    settings.userEmail = _emailController.text.trim();
    settings.categories = _categoryControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    settings.apiKey = _apiKeyController.text.trim();
    settings.onboarded = true;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
  }

  @override
  Widget build(BuildContext context) {
    final c = context.retro;
    final spacing = AppTheme.s4;

    return Scaffold(
      backgroundColor: c.paper,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
            },
            children: [
              _buildStep1(c, spacing),
              _buildStep2(c, spacing),
              _buildStep3(c, spacing),
              _buildStep4(c, spacing),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(c, spacing),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(RetroColors c, double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppTheme.s6),
          Text(
            'VOICENOTE',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: c.ink,
                  letterSpacing: 3,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.s3),
          Text(
            'ON-DEVICE VOICE NOTES. NO CLOUD REQUIRED.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.inkSoft,
                  letterSpacing: 1,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.s6),
          _buildTextInput(
            controller: _nameController,
            label: 'YOUR NAME (OPTIONAL)',
            c: c,
          ),
          SizedBox(height: spacing),
          _buildTextInput(
            controller: _emailController,
            label: 'EMAIL (OPTIONAL)',
            c: c,
          ),
          SizedBox(height: AppTheme.s6),
        ],
      ),
    );
  }

  Widget _buildStep2(RetroColors c, double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppTheme.s4),
          Text(
            'ORGANISE INTO PROJECTS',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: c.ink,
                  letterSpacing: 2,
                ),
          ),
          SizedBox(height: AppTheme.s4),
          ..._categoryControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: c.ink,
                            fontFamily: 'monospace',
                          ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: spacing,
                          vertical: spacing,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          borderSide: BorderSide(
                            color: c.border,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          borderSide: BorderSide(
                            color: c.border,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          borderSide: BorderSide(
                            color: c.accent,
                            width: AppTheme.borderWidth,
                          ),
                        ),
                        filled: true,
                        fillColor: c.surface,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close, color: c.ink, size: 18),
                      onPressed: () => _removeCategory(index),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: AppTheme.s3),
          TextButton(
            onPressed: _addCategory,
            child: Text(
              '+ ADD CATEGORY',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.accent,
                    letterSpacing: 1,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(RetroColors c, double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppTheme.s4),
          Text(
            'SMARTER NOTES (OPTIONAL)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: c.ink,
                  letterSpacing: 2,
                ),
          ),
          SizedBox(height: AppTheme.s4),
          Text(
            'This app transcribes fully offline on-device. Paste a FREE Groq API key to unlock AI formatting and auto-categorization—or skip for clean rule-based formatting.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.inkSoft,
                ),
          ),
          SizedBox(height: AppTheme.s4),
          _buildTextInput(
            controller: _apiKeyController,
            label: 'GROQ API KEY (OPTIONAL)',
            helperText: 'Free key at console.groq.com — or skip.',
            c: c,
          ),
          SizedBox(height: AppTheme.s6),
        ],
      ),
    );
  }

  Widget _buildStep4(RetroColors c, double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: AppTheme.s6),
          Text(
            'ALL SET',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: c.ink,
                  letterSpacing: 2,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.s4),
          Text(
            'Your voice notes are ready to capture.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.inkSoft,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.s6),
        ],
      ),
    );
  }

  Widget _buildBottomBar(RetroColors c, double spacing) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: c.border,
            width: AppTheme.borderWidth,
          ),
        ),
        color: c.paper,
      ),
      padding: EdgeInsets.all(spacing),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_currentStep + 1).toString().padLeft(2, '0')} / 04',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.inkSoft,
                        letterSpacing: 1,
                      ),
                ),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.accent,
                    foregroundColor: c.paper,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radius),
                    ),
                  ),
                  child: Text(
                    _currentStep == 3 ? 'START' : 'CONTINUE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: c.paper,
                          letterSpacing: 1,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required RetroColors c,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.ink,
            fontFamily: 'monospace',
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: c.inkSoft,
              letterSpacing: 1,
            ),
        helperText: helperText,
        helperStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: c.inkSoft,
              fontSize: 11,
            ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.s3,
          vertical: AppTheme.s3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(
            color: c.border,
            width: AppTheme.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(
            color: c.border,
            width: AppTheme.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(
            color: c.accent,
            width: AppTheme.borderWidth,
          ),
        ),
        filled: true,
        fillColor: c.surface,
      ),
    );
  }
}
