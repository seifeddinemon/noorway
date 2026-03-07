import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AladhanApiService {
  // Using HTTPS for security
  static const String _baseUrl = 'https://api.aladhan.com/v1/calendar';

  /// Returns the device's UTC offset in minutes (e.g., +180 for GMT+3)
  static int _getTimezoneOffset() {
    return DateTime.now().timeZoneOffset.inMinutes;
  }

  /// Fetches prayer times for the entire month from Aladhan API or local cache.
  ///
  /// [latitude]  : Device GPS latitude
  /// [longitude] : Device GPS longitude
  /// [method]    : Calculation method (1=Karachi, 2=ISNA, 3=MWL, 4=Umm Al Qura, 5=Egypt)
  /// [school]    : 0 = Shafi/Maliki/Hanbali, 1 = Hanafi (affects Asr time)
  static Future<List<dynamic>?> getMonthlyTimings({
    required double latitude,
    required double longitude,
    required int method,
    int school = 0,
  }) async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Cache key includes school and lat/lng rounded to 2 decimal places
    final cacheKey =
        'aladhan_v2_${year}_${month}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${method}_$school';
    final prefs = await SharedPreferences.getInstance();

    // 1. Serve from cache if available (supports offline mode)
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      debugPrint('Aladhan: Cache hit → $cacheKey');
      try {
        final decoded = json.decode(cachedData);
        if (decoded['code'] == 200) {
          return decoded['data'] as List<dynamic>;
        }
      } catch (e) {
        debugPrint('Aladhan: Cache parse error: $e');
      }
    }

    // 2. No cache — fetch from network
    debugPrint('Aladhan: Fetching from network → $cacheKey');
    try {
      final uri = Uri.parse(
        '$_baseUrl/$year/$month'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$method'
        '&school=$school',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          // 3. Save to cache for offline access
          await prefs.setString(cacheKey, response.body);
          debugPrint('Aladhan: Data cached for $cacheKey');
          return data['data'] as List<dynamic>;
        } else {
          debugPrint(
              'Aladhan: API returned code ${data['code']}: ${data['status']}');
        }
      } else {
        debugPrint('Aladhan: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Aladhan: Network error: $e');
    }

    // 4. Network failed — attempt expired cache from previous month
    debugPrint('Aladhan: Trying fallback cache...');
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final fallbackKey =
        'aladhan_v2_${prevYear}_${prevMonth}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${method}_$school';
    final fallback = prefs.getString(fallbackKey);
    if (fallback != null) {
      try {
        final decoded = json.decode(fallback);
        if (decoded['code'] == 200) {
          debugPrint('Aladhan: Serving expired fallback cache');
          return decoded['data'] as List<dynamic>;
        }
      } catch (_) {}
    }

    debugPrint('Aladhan: All sources failed. Returning null.');
    return null;
  }

  /// Clears all cached Aladhan data
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('aladhan_v2_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
    debugPrint('Aladhan: Cache cleared');
  }

  /// Returns the local timezone offset as a formatted string like "+03:00"
  static String getFormattedTimezoneOffset() {
    final offset = _getTimezoneOffset();
    final sign = offset >= 0 ? '+' : '-';
    final hours = (offset.abs() ~/ 60).toString().padLeft(2, '0');
    final minutes = (offset.abs() % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }
}
