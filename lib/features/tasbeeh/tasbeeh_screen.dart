import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/luxury_components.dart';
import '../../core/string_extensions.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _counter = 0;
  String _currentTheme = 'Subhan Allah';
  List<Map<String, dynamic>> _adhkarList = [];
  static const String _counterKey =
      'tasbeeh_counter_v2'; // reset for new structure
  static const String _adhkarKey = 'tasbeeh_adhkar_list';

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_counterKey) ?? 0;
      _currentTheme =
          prefs.getString('tasbeeh_current_theme') ?? 'Subhan Allah';

      final savedList = prefs.getStringList(_adhkarKey);
      if (savedList != null && savedList.isNotEmpty) {
        _adhkarList = savedList.map((item) {
          final parts = item.split('|');
          return {'name': parts[0], 'target': int.tryParse(parts[1]) ?? 33};
        }).toList();
      } else {
        // Defaults
        _adhkarList = [
          {'name': 'Subhan Allah', 'target': 33},
          {'name': 'Alhamdulillah', 'target': 33},
          {'name': 'Allahu Akbar', 'target': 33},
        ];
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
    await prefs.setString('tasbeeh_current_theme', _currentTheme);
    final stringList =
        _adhkarList.map((e) => '${e['name']}|${e['target']}').toList();
    await prefs.setStringList(_adhkarKey, stringList);
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });
    await _saveState();
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);

    // Provide a stronger feedback pattern if a target is reached
    final currentTarget = _adhkarList.firstWhere(
      (d) => d['name'] == _currentTheme,
      orElse: () => {'target': 33},
    )['target'];

    if (currentTarget > 0 && _counter % currentTarget == 0) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 150), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  Future<void> _resetCounter() async {
    setState(() => _counter = 0);
    await _saveState();
    HapticFeedback.mediumImpact();
  }

  void _showAddDhikrSheet() {
    final lang =
        Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    String newName = '';
    String newTarget = '33';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border:
                  Border(top: BorderSide(color: AppColors.royalGold, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang == 'ar' ? 'إضافة ذكر جديد' : 'Add New Dhikr',
                  style: const TextStyle(
                    color: AppColors.royalGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang == 'ar' ? 'اسم الذكر' : 'Dhikr Name',
                    labelStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.royalGold)),
                  ),
                  onChanged: (val) => newName = val,
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: lang == 'ar'
                        ? 'الهدف (اختياري، افتراضي 33)'
                        : 'Target (Optional, Default 33)',
                    labelStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.royalGold)),
                  ),
                  onChanged: (val) => newTarget = val,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (newName.trim().isNotEmpty) {
                      setState(() {
                        _adhkarList.add({
                          'name': newName.trim(),
                          'target': int.tryParse(newTarget) ?? 33,
                        });
                        _currentTheme = newName.trim();
                        _counter = 0;
                      });
                      _saveState();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    AppStrings.get('confirm', lang),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDhikrSelectionSheet() {
    final lang =
        Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border:
                Border(top: BorderSide(color: AppColors.royalGold, width: 2)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  lang == 'ar' ? 'اختر الذكر' : 'Select Dhikr',
                  style: const TextStyle(
                    color: AppColors.royalGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _adhkarList.length,
                  itemBuilder: (context, index) {
                    final dhikr = _adhkarList[index];
                    final isSelected = dhikr['name'] == _currentTheme;
                    return ListTile(
                      title: Text(
                        dhikr['name'],
                        style: TextStyle(
                          color:
                              isSelected ? AppColors.royalGold : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.royalGold)
                          : null,
                      onTap: () {
                        setState(() {
                          _currentTheme = dhikr['name'];
                          _counter = 0;
                        });
                        _saveState();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounterDisplay(double screenWidth) {
    final hPad = screenWidth * 0.12;
    final vPad = screenWidth * 0.07;
    final fontSize = screenWidth * 0.18;
    return Stack(
      children: [
        LuxuryGlassCard(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          borderRadius: 40,
          child: Text(
            '$_counter'.toWesternDigits(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'NotoKufiArabic',
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _resetCounter,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.royalGold.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.royalGold,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrHeader() {
    return GestureDetector(
      onTap: _showDhikrSelectionSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.royalGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentTheme,
              style: const TextStyle(
                color: AppColors.royalGold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.royalGold),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBead(double screenWidth) {
    final outerSize = screenWidth * 0.7;
    final radius = outerSize * 0.46;
    final innerSize = outerSize * 0.70;
    final beadDotSize = outerSize * 0.04;
    return GestureDetector(
      onTap: _incrementCounter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
          ),
          ...List.generate(33, (index) {
            final angle = (index * 2 * math.pi) / 33;
            return Transform.translate(
              offset:
                  Offset(radius * math.cos(angle), radius * math.sin(angle)),
              child: Container(
                width: beadDotSize,
                height: beadDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.royalGold
                      .withValues(alpha: index < (_counter % 33) ? 0.8 : 0.1),
                  boxShadow: [
                    if (index < (_counter % 33))
                      BoxShadow(
                          color: AppColors.royalGold.withValues(alpha: 0.3),
                          blurRadius: 8),
                  ],
                ),
              ),
            );
          }),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.royalGold.withValues(alpha: 0.15),
                  Colors.transparent
                ],
              ),
            ),
            child: LuxuryGlassCard(
              borderRadius: 100,
              padding: EdgeInsets.zero,
              child: Icon(Icons.touch_app_rounded,
                  color: AppColors.royalGold, size: outerSize * 0.22),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.04;
    final beadTopPadding = screenHeight * 0.05;

    return LuxuryScaffold(
      title: AppStrings.get('tasbeeh', lang),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDhikrSheet,
        backgroundColor: AppColors.royalGold,
        child: const Icon(Icons.add, color: AppColors.darkBackground, size: 28),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildDhikrHeader(),
            SizedBox(height: screenHeight * 0.03),
            _buildCounterDisplay(screenWidth),
            SizedBox(height: beadTopPadding),
            _buildMainBead(screenWidth),
          ],
        ),
      ),
    );
  }
}
