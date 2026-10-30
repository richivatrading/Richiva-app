import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.explore_outlined,
      title: 'Discover',
      body: 'Browse curated collections, flash sales, and personalized recommendations. Your style, one tap away.',
      color: Color(0xFF6366F1),
    ),
    _SlideData(
      icon: Icons.remove_red_eye_outlined,
      title: 'Details that matter',
      body: 'Zoom into fabrics, read verified reviews, watch fit videos, and compare sizes — all on the product page.',
      color: Color(0xFF06B6D4),
    ),
    _SlideData(
      icon: Icons.camera_front_outlined,
      title: 'Try before you buy',
      body: 'Use the virtual Try-On to see how pieces look on you in real time. Confidence delivered.',
      color: Color(0xFF10B981),
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── PageView
            PageView(
              controller: _pageCtrl,
              onPageChanged: (p) => setState(() => _page = p),
              children: _slides.map((s) => _SlideWidget(slide: s)).toList(),
            ),

            // ── Bottom controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.s24, AppTheme.s16, AppTheme.s24, AppTheme.s24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _page
                                  ? _slides[_page].color
                                  : AppTheme.border,
                              borderRadius: BorderRadius.circular(AppTheme.rPill),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppTheme.s24),

                      // Action buttons
                      Row(
                        children: [
                          if (_page < _slides.length - 1)
                            Expanded(
                              child: TextButton(
                                onPressed: () => _complete(),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          if (_page < _slides.length - 1) ...[
                            const SizedBox(width: AppTheme.s12),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () {
                                  _pageCtrl.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: const Text('Next'),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: FilledButton(
                                onPressed: _complete,
                                child: const Text('Get started'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}

class _SlideWidget extends StatelessWidget {
  final _SlideData slide;
  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  slide.color.withValues(alpha: 0.3),
                  slide.color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 56, color: slide.color),
          ),
          const SizedBox(height: AppTheme.s32),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: slide.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.s16),
          Text(
            slide.body,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textMuted,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}