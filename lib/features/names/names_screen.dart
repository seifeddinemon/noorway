import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/luxury_components.dart';
import '../../core/string_extensions.dart';
import '../../data/models/name_of_allah.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  List<NameOfAllah> _names = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final String response =
        await rootBundle.loadString('assets/data/names_of_allah.json');
    final data = await json.decode(response);
    setState(() {
      _names = (data as List).map((i) => NameOfAllah.fromJson(i)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: AppStrings.get('names_of_allah', lang),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.royalGold))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _names.length,
              itemBuilder: (context, index) {
                final name = _names[index];
                return _buildNameCard(name, lang);
              },
            ),
    );
  }

  Widget _buildNameCard(NameOfAllah name, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.royalGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${name.id}'.toWesternDigits(),
              style: const TextStyle(
                  color: AppColors.royalGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Text(
            name.nameAr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'NotoKufiArabic',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name.nameEn,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.royalGold,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            name.meaning,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.3),
          ),
        ],
      ),
    );
  }
}
