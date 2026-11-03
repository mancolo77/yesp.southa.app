import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeoService {
  /// Fetches the user's 2-letter ISO country code (e.g. 'RU', 'DE', 'KG', 'KZ', 'GB')
  /// exclusively based on the user's IP address.
  /// Queries 4 public geolocation providers simultaneously and returns immediately
  /// upon the FASTEST successful response.
  static Future<String?> getCountryCode() async {
    final completer = Completer<String?>();
    int pending = 4;

    void onResult(String? code) {
      if (!completer.isCompleted) {
        if (code != null && RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
          if (kDebugMode) {
            print('[GeoService] Detected country by IP (fastest provider): $code');
          }
          completer.complete(code);
          return;
        }
        pending--;
        if (pending <= 0) {
          completer.complete(null);
        }
      }
    }

    _fetchFromCountryIs().then(onResult).catchError((_) => onResult(null));
    _fetchFromGeoJs().then(onResult).catchError((_) => onResult(null));
    _fetchFromMyIp().then(onResult).catchError((_) => onResult(null));
    _fetchFromIpWhoIs().then(onResult).catchError((_) => onResult(null));

    // Overall timeout 2.5s
    return completer.future.timeout(
      const Duration(milliseconds: 2500),
      onTimeout: () => null,
    );
  }

  /// Provider 1: geojs (https://get.geojs.io/v1/ip/country.json)
  static Future<String?> _fetchFromGeoJs() async {
    try {
      final response = await http
          .get(Uri.parse('https://get.geojs.io/v1/ip/country.json'))
          .timeout(const Duration(milliseconds: 1500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final code = (data['country'] ?? data['country_code'])?.toString().trim().toUpperCase();
          if (code != null && code.length == 2) {
            return code;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Provider 2: country.is (https://api.country.is/)
  static Future<String?> _fetchFromCountryIs() async {
    for (final url in ['https://api.country.is/', 'https://country.is']) {
      try {
        final response = await http
            .get(Uri.parse(url), headers: {'Accept': 'application/json'})
            .timeout(const Duration(milliseconds: 1500));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            final code = (data['country'] ?? data['country_code'])?.toString().trim().toUpperCase();
            if (code != null && code.length == 2) {
              return code;
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Provider 3: myip (https://api.myip.com)
  static Future<String?> _fetchFromMyIp() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.myip.com'))
          .timeout(const Duration(milliseconds: 1500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final code = (data['cc'] ?? data['country_code'] ?? data['country'])
              ?.toString()
              .trim()
              .toUpperCase();
          if (code != null && code.length == 2) {
            return code;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Redundant Fallback Provider: ipwho.is
  static Future<String?> _fetchFromIpWhoIs() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(milliseconds: 1500));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['success'] == true) {
          final code = data['country_code']?.toString().trim().toUpperCase();
          if (code != null && code.length == 2) {
            return code;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
