import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/last_reading_provider.dart';
import '../../core/luxury_components.dart';
import '../../data/models/azkar_item.dart';

class AzkarListScreen extends StatefulWidget {
  final String categoryType;
  final String categoryTitle;

  const AzkarListScreen({
    super.key,
    required this.categoryType,
    required this.categoryTitle,
  });

  @override
  State<AzkarListScreen> createState() => _AzkarListScreenState();
}

class _AzkarListScreenState extends State<AzkarListScreen> {
  List<AzkarItem> _allAzkar = [];
  List<AzkarItem> _filteredAzkar = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    final String response =
        await rootBundle.loadString('assets/data/azkar.json');
    final List<dynamic> data = await json.decode(response);
    final items = data.map((i) => AzkarItem.fromJson(i)).toList();

    setState(() {
      _allAzkar =
          items.where((item) => item.type == widget.categoryType).toList();
      _filteredAzkar = _allAzkar;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastPos = Provider.of<LastReadingProvider>(context, listen: false)
          .getLastIndex(widget.categoryType);
      if (lastPos > 0 && lastPos < _allAzkar.length) {
        _scrollController.animateTo(lastPos * 180.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });

    _scrollController.addListener(() {
      final index = (_scrollController.offset / 180.0).round();
      if (index >= 0 && index < _allAzkar.length) {
        Provider.of<LastReadingProvider>(context, listen: false)
            .savePosition(widget.categoryType, index);
      }
    });
  }

  void _filterAzkar(String query) {
    setState(() {
      _filteredAzkar = _allAzkar.where((item) {
        return item.textAr.contains(query) ||
            item.textEn.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: widget.categoryTitle,
      body: Column(
        children: [
          _buildSearchBar(lang),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.royalGold))
                : _filteredAzkar.isEmpty
                    ? Center(
                        child: Text(AppStrings.get('no_items_found', lang),
                            style: const TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: _filteredAzkar.length,
                        itemBuilder: (context, index) {
                          return _buildAzkarCard(_filteredAzkar[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String lang) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LuxuryGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          onChanged: _filterAzkar,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppStrings.get('search', lang),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.15)),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.15)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarCard(AzkarItem item) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, child) {
        final isFav = favProvider.isFavorite(item);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: LuxuryGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.textAr,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Amiri',
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                Text(
                  item.textEn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.15),
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.royalGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.royalGold.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        item.source,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.royalGold,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: isFav ? Colors.redAccent : Colors.white24,
                      ),
                      onPressed: () {
                        favProvider.toggleFavorite(item);
                        if (!isFav) HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
