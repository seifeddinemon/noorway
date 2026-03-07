import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/prayer_times_provider.dart';
import '../../core/user_provider.dart';
import '../../core/theme_provider.dart';
import '../azkar/favorites_screen.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final List<Widget> pages = [
      _buildHomeContent(context, prayerProvider, userProvider, lang),
      const FavoritesScreen(),
      _buildSettingsContent(context, lang),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryEmerald,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppStrings.get('home', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: AppStrings.get('favorites', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppStrings.get('settings', lang),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Solid Deep Emerald to Soft Grey Vertical Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.deepGradientGreen,
                  const Color(0xFF0F172A), // Very deep navy/emerald
                  AppColors.lightBackground,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 2. Liquid Gold Glowing Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.royalGold.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalGold.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryEmerald.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                    blurRadius: 150,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          // 3. Subtle Islamic Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: Image.asset(
                'assets/images/islamic_compass_pattern.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),

          // 4. Golden Decorative Header Pattern
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.royalGold.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Image.asset(
                'assets/images/islamic_compass_pattern.png',
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),

          // 4. Actual Page Content
          SafeArea(child: pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, String lang) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(AppStrings.get('settings', lang)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSettingsSection(
                  title: AppStrings.get('language', lang),
                  icon: Icons.language,
                  trailing: Switch(
                    value: localeProvider.isArabic,
                    onChanged: (v) => localeProvider.toggleLocale(),
                    activeThumbColor: AppColors.primaryEmerald,
                  ),
                  subtitle: localeProvider.isArabic ? 'العربية' : 'English',
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  title: AppStrings.get('theme_dark_mode', lang),
                  icon: Icons.dark_mode,
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) themeProvider.setThemeMode(mode);
                    },
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(AppStrings.get('theme_system', lang)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(AppStrings.get('theme_light', lang)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(AppStrings.get('theme_dark', lang)),
                      ),
                    ],
                  ),
                  subtitle: AppStrings.get('theme_change_subtitle', lang),
                ),
                const SizedBox(height: 16),
                _buildSettingsSection(
                  title: AppStrings.get('user_name', lang),
                  icon: Icons.person_outline_rounded,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.primaryEmerald),
                    onPressed: () => _showNameEditDialog(context, lang),
                  ),
                  subtitle: Provider.of<UserProvider>(context).userName.isEmpty
                      ? AppStrings.get('enter_name', lang)
                      : Provider.of<UserProvider>(context).userName,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryEmerald),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, String lang) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final controller = TextEditingController(text: userProvider.userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF04100D),
        title: Text(
          AppStrings.get('edit_name', lang),
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppStrings.get('enter_name', lang),
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.royalGold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.get('cancel', lang),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.setUserName(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalGold,
              foregroundColor: AppColors.primaryEmerald,
            ),
            child: Text(AppStrings.get('save_name', lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    PrayerTimesProvider prayerProvider,
    UserProvider userProvider,
    String lang,
  ) {
    return Column(
      children: [
        // 1. Fixed Top Header
        Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('app_name', lang),
                    style: const TextStyle(
                      color: AppColors.softGoldHighlight,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.royalGold, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        prayerProvider.locationName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.language,
                    color: AppColors.softGoldHighlight),
                onPressed: () => Provider.of<LocaleProvider>(
                  context,
                  listen: false,
                ).toggleLocale(),
              ),
            ],
          ),
        ),

        // 2. Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingArea(lang, userProvider.userName),
                  const SizedBox(height: 24),
                  _buildPrayerTimesCard(context, prayerProvider, lang),
                  const SizedBox(height: 32),
                  _buildMainActionsGrid(context, lang),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingArea(String lang, String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName.isNotEmpty
              ? '${AppStrings.get('greeting', lang)}, $userName'
              : AppStrings.get('greeting', lang),
          style: const TextStyle(
            fontSize: 32, // Slightly larger
            fontWeight: FontWeight.w900, // Bolder
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.royalGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_rounded,
                  size: 16, color: AppColors.primaryEmerald),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.get('hijri_date', lang)}: ${DateFormat.yMMMMd(lang).format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.royalGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesCard(
    BuildContext context,
    PrayerTimesProvider provider,
    String lang,
  ) {
    final prayers = [
      {
        'name': provider.getPrayerName(Prayer.fajr, lang),
        'time': provider.timeForPrayer(Prayer.fajr),
        'id': Prayer.fajr,
      },
      {
        'name': provider.getPrayerName(Prayer.dhuhr, lang),
        'time': provider.timeForPrayer(Prayer.dhuhr),
        'id': Prayer.dhuhr,
      },
      {
        'name': provider.getPrayerName(Prayer.asr, lang),
        'time': provider.timeForPrayer(Prayer.asr),
        'id': Prayer.asr,
      },
      {
        'name': provider.getPrayerName(Prayer.maghrib, lang),
        'time': provider.timeForPrayer(Prayer.maghrib),
        'id': Prayer.maghrib,
      },
      {
        'name': provider.getPrayerName(Prayer.isha, lang),
        'time': provider.timeForPrayer(Prayer.isha),
        'id': Prayer.isha,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryEmerald,
                AppColors.deepGradientGreen,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15, // Increased from 0.05
                  child: Image.asset(
                    'assets/images/islamic_compass_pattern.png',
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),
              // Corner Ornaments
              Positioned(
                  top: 12,
                  left: 12,
                  child: Icon(Icons.diamond,
                      color: AppColors.royalGold.withValues(alpha: 0.15),
                      size: 16)),
              Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(Icons.diamond,
                      color: AppColors.royalGold.withValues(alpha: 0.15),
                      size: 16)),
              Positioned(
                  bottom: 12,
                  left: 12,
                  child: Icon(Icons.diamond,
                      color: AppColors.royalGold.withValues(alpha: 0.15),
                      size: 16)),
              Positioned(
                  bottom: 12,
                  right: 12,
                  child: Icon(Icons.diamond,
                      color: AppColors.royalGold.withValues(alpha: 0.15),
                      size: 16)),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.getPrayerName(provider.nextPrayer, lang),
                              style: const TextStyle(
                                color: AppColors.softGoldHighlight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.get('next_prayer', lang),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.mosque,
                          color: AppColors.softGoldHighlight,
                          size: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: prayers.map((p) {
                        final isNext = provider.nextPrayer == p['id'];
                        return _prayerTimeItem(
                          p['name']! as String,
                          p['time'] != null
                              ? DateFormat.jm().format(p['time'] as DateTime)
                              : '--:--',
                          isNext,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prayerTimeItem(String label, String time, bool isNext) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isNext ? AppColors.softGoldHighlight : Colors.white70,
            fontSize: 10,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: isNext ? AppColors.softGoldHighlight : Colors.white,
            fontSize: 12,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionsGrid(BuildContext context, String lang) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': AppStrings.get('quran', lang),
        'image': 'assets/images/quran_icon.png',
        'route': '/quran',
      },
      {
        'title': AppStrings.get('azkar', lang),
        'image': 'assets/images/azkar_icon.png',
        'route': '/azkar',
      },
      {
        'title': AppStrings.get('names_of_allah', lang),
        'image': 'assets/images/names_icon.png',
        'route': '/names',
      },
      {
        'title': AppStrings.get('prayer_times', lang),
        'image': 'assets/images/prayer_times_icon.png',
        'route': '/prayer-times',
      },
      {
        'title': AppStrings.get('qibla', lang),
        'image': 'assets/images/qibla_icon.png',
        'route': '/qibla',
      },
      {
        'title': AppStrings.get('tasbeeh', lang),
        'image': 'assets/images/tasbeeh_icon.png',
        'route': '/tasbeeh',
      },
      {
        'title': AppStrings.get('favorites', lang),
        'image': 'assets/images/favorites_icon.png',
        'route': '/favorites',
      },
      {
        'title': AppStrings.get('stories_of_prophets', lang),
        'image': 'assets/images/stories_icon.png',
        'route': '/stories',
      },
      {
        'title': AppStrings.get('premium_ui', lang),
        'image': 'assets/images/splash_logo.png',
        'route': '/premium-dashboard',
      },
      {
        'title': AppStrings.get('knowledge_challenge', lang),
        'image': 'assets/images/quiz_icon.png',
        'route': '/quiz',
      },
      {
        'title': AppStrings.get('adhan_settings', lang),
        'image': 'assets/images/adhan_settings_icon.png',
        'route': '/adhan-settings',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final hasImage = action.containsKey('image');

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, action['route']),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1),
                        boxShadow: [
                          if (hasImage)
                            BoxShadow(
                              color:
                                  AppColors.royalGold.withValues(alpha: 0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: hasImage
                          ? Image.asset(
                              action['image'] as String,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image,
                                      size: 36, color: Colors.white),
                            )
                          : Icon(
                              action['icon'] as IconData,
                              size: 36,
                              color: action['color'] as Color,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
