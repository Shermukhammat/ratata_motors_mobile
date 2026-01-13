import 'package:flutter/material.dart';
import 'package:ratata_motors/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ======================
///  DATA MODEL
/// ======================
class Board {
  final String titleEn;
  final String subtitleEn;
  final String titleAr;
  final String subtitleAr;
  final IconData icon;
  final Color? accentColor;

  const Board({
    required this.titleEn,
    required this.subtitleEn,
    required this.titleAr,
    required this.subtitleAr,
    required this.icon,
    this.accentColor,
  });

  String title(String? lang) => lang == 'ar' ? titleAr : titleEn;
  String subtitle(String? lang) => lang == 'ar' ? subtitleAr : subtitleEn;
}

const List<Board> onboardingBoards = [
  Board(
    icon: Icons.verified_rounded,
    titleEn: 'Halal installment cars',
    subtitleEn: '0% interest. Transparent and fair terms.',
    titleAr: 'سيارات بالتقسيط بشروط حلال',
    subtitleAr: '0% فائدة وشروط واضحة وعادلة.',
    accentColor: Colors.green,
  ),
  Board(
    icon: Icons.account_balance_rounded,
    titleEn: 'No banks involved',
    subtitleEn: 'Simple process without bank financing.',
    titleAr: 'بدون بنوك',
    subtitleAr: 'إجراءات سهلة بدون تمويل بنكي.',
    accentColor: Colors.blue,
  ),
  Board(
    icon: Icons.bolt_rounded,
    titleEn: 'Fast approval',
    subtitleEn: 'Get approved in about 15 minutes.',
    titleAr: 'موافقة سريعة',
    subtitleAr: 'الحصول على الموافقة خلال حوالي 15 دقيقة.',
    accentColor: Colors.orange,
  ),
  Board(
    icon: Icons.badge_rounded,
    titleEn: 'Simple documents',
    subtitleEn: 'Emirates ID + driving license.',
    titleAr: 'مستندات بسيطة',
    subtitleAr: 'الهوية الإماراتية + رخصة القيادة.',
    accentColor: Colors.purple,
  ),
];

/// ======================
///  MAIN ONBOARDING PAGE
/// ======================
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}
class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _pageIndex = 0;
  String? _lang;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool get _isArabic => _lang == 'ar';
  int get _totalPages => 1 + onboardingBoards.length;
  bool get _canContinue => _pageIndex == 0 ? _lang != null : true;
  
  String _t({required String en, required String ar}) => _lang == 'ar' ? ar : en;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _next() {
    if (_pageIndex < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // This is the “switch to login”
      ref.read(appControllerProvider.notifier).completeOnboarding();
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final maxWidth = isTablet ? 500.0 : double.infinity;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  // Top spacing
                  SizedBox(height: isTablet ? 16 : 8),

                  // Pages
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (i) {
                        setState(() => _pageIndex = i);
                        _fadeController.reset();
                        _fadeController.forward();
                      },
                      children: [
                        LanguageWelcomeStep(
                          lang: _lang,
                          onSelect: (code) => setState(() => _lang = code),
                          isTablet: isTablet,
                        ),
                        ...onboardingBoards.map(
                              (b) => BoardPage(
                            board: b,
                            lang: _lang,
                            fadeAnimation: _fadeAnimation,
                            isTablet: isTablet,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom: dots + button
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 24 : 16,
                      12,
                      isTablet ? 24 : 16,
                      isTablet ? 32 : 24,
                    ),
                    child: Column(
                      children: [
                        Dots(count: _totalPages, index: _pageIndex),
                        SizedBox(height: isTablet ? 20 : 16),
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 56 : 52,
                          child: FilledButton(
                            onPressed: _canContinue ? _next : null,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _pageIndex < _totalPages - 1
                                      ? _t(en: 'Continue', ar: 'متابعة')
                                      : _t(en: 'Get Started', ar: 'ابدأ الآن'),
                                  style: TextStyle(
                                    fontSize: isTablet ? 17 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_pageIndex == _totalPages - 1) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    _isArabic
                                        ? Icons.arrow_back_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================
///  PAGE 1: LANGUAGE WELCOME
/// ======================
class LanguageWelcomeStep extends StatelessWidget {
  final String? lang;
  final ValueChanged<String> onSelect;
  final bool isTablet;

  const LanguageWelcomeStep({
    super.key,
    required this.lang,
    required this.onSelect,
    this.isTablet = false,
  });

  bool get _isArabic => lang == 'ar';
  String _t({required String en, required String ar}) => _isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget langCard({
      required String code,
      required String title,
      required String subtitle,
      required String badge,
    }) {
      final selected = lang == code;

      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelect(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isTablet ? 18 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: selected ? 2 : 1.5,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
              color: selected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
              boxShadow: [
                if (selected)
                  BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    color: theme.colorScheme.primary.withOpacity(0.15),
                  ),
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 56 : 48,
                  height: isTablet ? 56 : 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: TextStyle(fontSize: isTablet ? 28 : 24),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isTablet ? 20 : 18,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: isTablet ? 15 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: selected ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    size: isTablet ? 28 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        isTablet ? 20 : 16,
        isTablet ? 32 : 20,
        isTablet ? 24 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isTablet ? 24 : 16),

          // App logo or icon (optional)
          Container(
            width: isTablet ? 80 : 64,
            height: isTablet ? 80 : 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              size: isTablet ? 40 : 32,
              color: Colors.white,
            ),
          ),

          SizedBox(height: isTablet ? 28 : 20),

          Text(
            _t(en: 'Welcome to Ratata Motors', ar: 'مرحبًا بك في راتاتا موتورز'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: isTablet ? 32 : 28,
              height: 1.2,
            ),
          ),
          SizedBox(height: isTablet ? 14 : 12),
          Text(
            _t(
              en: 'Choose your preferred language to get started.',
              ar: 'اختر اللغة المفضلة لديك للبدء.',
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
              fontSize: isTablet ? 17 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          langCard(
            code: 'en',
            title: 'English',
            subtitle: 'Continue in English',
            badge: '🇬🇧',
          ),
          SizedBox(height: isTablet ? 16 : 12),
          langCard(
            code: 'ar',
            title: 'العربية',
            subtitle: 'المتابعة بالعربية',
            badge: '🇦🇪',
          ),

          SizedBox(height: isTablet ? 32 : 24),

          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: isTablet ? 22 : 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _t(
                      en: 'You can change the language anytime in Settings.',
                      ar: 'يمكنك تغيير اللغة في أي وقت من الإعدادات.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: isTablet ? 14 : 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
///  BOARD PAGES
/// ======================
class BoardPage extends StatelessWidget {
  final Board board;
  final String? lang;
  final Animation<double> fadeAnimation;
  final bool isTablet;

  const BoardPage({
    super.key,
    required this.board,
    required this.lang,
    required this.fadeAnimation,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = board.accentColor ?? theme.colorScheme.primary;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 32 : 24,
          isTablet ? 32 : 24,
          isTablet ? 32 : 24,
          isTablet ? 24 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isTablet ? 40 : 24),

            // Animated icon container
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: isTablet ? 88 : 76,
                height: isTablet ? 88 : 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.15),
                      accentColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      color: accentColor.withOpacity(0.2),
                    ),
                  ],
                ),
                child: Icon(
                  board.icon,
                  size: isTablet ? 42 : 36,
                  color: accentColor,
                ),
              ),
            ),

            SizedBox(height: isTablet ? 36 : 28),

            Text(
              board.title(lang),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: isTablet ? 32 : 28,
                height: 1.2,
              ),
            ),

            SizedBox(height: isTablet ? 18 : 14),

            Text(
              board.subtitle(lang),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
                fontSize: isTablet ? 18 : 17,
              ),
            ),

            SizedBox(height: isTablet ? 48 : 32),

            // Decorative element
            Container(
              height: 4,
              width: isTablet ? 80 : 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================
///  DOTS INDICATOR
/// ======================
class Dots extends StatelessWidget {
  final int count;
  final int index;

  const Dots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 5 : 4),
          height: isTablet ? 10 : 8,
          width: active ? (isTablet ? 28 : 24) : (isTablet ? 10 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
            boxShadow: active
                ? [
              BoxShadow(
                blurRadius: 8,
                color: theme.colorScheme.primary.withOpacity(0.4),
              ),
            ]
                : null,
          ),
        );
      }),
    );
  }
}