import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  static const String _rateKey = 'exchange_rate_mad_usd';
  static const String _lastUpdateKey = 'exchange_rate_last_update';

  // Default fallback rate if API fails
  static const double _fallbackRate = 0.099;

  // Cache duration: 1 hour (rates don't change that frequently)
  static const Duration _cacheDuration = Duration(hours: 1);

  // Fetch current MAD to USD exchange rate
  static Future<double> fetchMadToUsdRate() async {
    try {
      // Check if we have a cached rate that's still valid
      final cachedRate = await _getCachedRate();
      if (cachedRate != null) {
        return cachedRate;
      }

      // Fetch from free exchange rate API
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/MAD'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final usdRate = (rates['USD'] as num).toDouble();

        // Cache the rate
        await _cacheRate(usdRate);

        return usdRate;
      } else {
        // Try alternative API
        return await _fetchFromAlternativeApi();
      }
    } catch (e) {
      // Try alternative API on error
      try {
        return await _fetchFromAlternativeApi();
      } catch (_) {
        // Return cached rate if available, otherwise fallback
        final prefs = await SharedPreferences.getInstance();
        return prefs.getDouble(_rateKey) ?? _fallbackRate;
      }
    }
  }

  // Alternative API in case primary fails
  static Future<double> _fetchFromAlternativeApi() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/MAD'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final usdRate = (rates['USD'] as num).toDouble();

        await _cacheRate(usdRate);
        return usdRate;
      }
    } catch (_) {}

    // Return cached or fallback
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_rateKey) ?? _fallbackRate;
  }

  // Cache the rate locally
  static Future<void> _cacheRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rateKey, rate);
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached rate if still valid
  static Future<double?> _getCachedRate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);

    if (lastUpdate != null) {
      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      if (DateTime.now().difference(lastUpdateTime) < _cacheDuration) {
        return prefs.getDouble(_rateKey);
      }
    }
    return null;
  }

  // Get the last cached rate (even if expired) for offline use
  static Future<double> getCachedOrFallbackRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_rateKey) ?? _fallbackRate;
  }

  // Get last update time
  static Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    if (lastUpdate != null) {
      return DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    }
    return null;
  }
}
