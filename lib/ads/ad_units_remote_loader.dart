import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ad_config.dart';

/// Fetches ad unit IDs from a URL (default: shared Google Drive file).
///
/// Expected JSON (recommended — real AdMob units differ per platform):
/// ```json
/// {
///   "ios": {
///     "appOpen": "ca-app-pub-…/…",
///     "banner": "…",
///     "rewarded": "…",
///     "interstitial": "…"
///   },
///   "android": {
///     "appOpen": "…",
///     "banner": "…",
///     "rewarded": "…",
///     "interstitial": "…"
///   }
/// }
/// ```
///
/// Alternate flat form (same four strings used on **both** platforms):
/// ```json
/// {
///   "appOpen": "…",
///   "banner": "…",
///   "rewarded": "…",
///   "interstitial": "…"
/// }
/// ```
///
/// Use `0`, `""`, or omit a key to disable that placement. Keys also accept snake_case: `app_open`, etc.
///
/// Override the URL at build time:
/// `flutter run --dart-define=AD_UNITS_JSON_URL=https://…`
abstract final class AdUnitsRemoteLoader {
  /// File id from:
  /// `https://drive.google.com/file/d/1lp6XGt4OS0Qa9Y8nIldSzh0KvQuh9WnQ/view`
  static const String _kDriveFileId = '1lp6XGt4OS0Qa9Y8nIldSzh0KvQuh9WnQ';

  static const String _kDefaultUrl =
      'https://drive.google.com/uc?export=download&id=$_kDriveFileId';

  static String get _configUrl {
    const fromEnv = String.fromEnvironment('AD_UNITS_JSON_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return _kDefaultUrl;
  }

  /// Loads remote JSON and updates [AdConfig]. On failure or invalid payload, units stay empty (no ads).
  static Future<void> load() async {
    try {
      final uri = Uri.parse(_configUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'AdUnitsRemoteLoader: HTTP ${response.statusCode} for $_configUrl',
        );
        return;
      }
      final body = response.body.trim();
      if (body.isEmpty ||
          body.startsWith('<!') ||
          body.startsWith('<html')) {
        debugPrint(
          'AdUnitsRemoteLoader: response is not JSON (Drive may need a '
          'different hosting URL). Use --dart-define=AD_UNITS_JSON_URL=… '
          'or host the same JSON on a raw URL.',
        );
        return;
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('AdUnitsRemoteLoader: root JSON must be an object.');
        return;
      }
      _applyJson(decoded);
    } on Object catch (e, st) {
      debugPrint('AdUnitsRemoteLoader: $e\n$st');
    }
  }

  /// `null` = missing, `0`, empty, or unusable → caller treats as disabled.
  static String? _pickOptionalUnit(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (!m.containsKey(k)) continue;
      final v = m[k];
      if (v == null) return null;
      if (v is num && v == 0) return null;
      if (v is String) {
        final t = v.trim();
        if (t.isEmpty || t == '0') return null;
        return t;
      }
      final s = v.toString().trim();
      if (s.isEmpty || s == '0') return null;
      return s;
    }
    return null;
  }

  static void _applyJson(Map<String, dynamic> root) {
    Map<String, dynamic>? asMap(Object? o) {
      if (o is Map<String, dynamic>) return o;
      if (o is Map) return Map<String, dynamic>.from(o);
      return null;
    }

    void apply({
      String? iosAppOpen,
      String? iosBanner,
      String? iosRewarded,
      String? iosInterstitial,
      String? androidAppOpen,
      String? androidBanner,
      String? androidRewarded,
      String? androidInterstitial,
    }) {
      AdConfig.applyRemoteUnits(
        iosAppOpen: iosAppOpen,
        iosBanner: iosBanner,
        iosRewarded: iosRewarded,
        iosInterstitial: iosInterstitial,
        androidAppOpen: androidAppOpen,
        androidBanner: androidBanner,
        androidRewarded: androidRewarded,
        androidInterstitial: androidInterstitial,
      );
    }

    final iosBlock = asMap(root['ios']);
    final androidBlock = asMap(root['android']);

    if (iosBlock != null && androidBlock != null) {
      apply(
        iosAppOpen: _pickOptionalUnit(iosBlock, const ['appOpen', 'app_open']),
        iosBanner: _pickOptionalUnit(iosBlock, const ['banner']),
        iosRewarded: _pickOptionalUnit(iosBlock, const ['rewarded']),
        iosInterstitial: _pickOptionalUnit(iosBlock, const ['interstitial']),
        androidAppOpen:
            _pickOptionalUnit(androidBlock, const ['appOpen', 'app_open']),
        androidBanner: _pickOptionalUnit(androidBlock, const ['banner']),
        androidRewarded: _pickOptionalUnit(androidBlock, const ['rewarded']),
        androidInterstitial:
            _pickOptionalUnit(androidBlock, const ['interstitial']),
      );
      return;
    }

    apply(
      iosAppOpen: _pickOptionalUnit(root, const ['appOpen', 'app_open']),
      iosBanner: _pickOptionalUnit(root, const ['banner']),
      iosRewarded: _pickOptionalUnit(root, const ['rewarded']),
      iosInterstitial: _pickOptionalUnit(root, const ['interstitial']),
      androidAppOpen: _pickOptionalUnit(root, const ['appOpen', 'app_open']),
      androidBanner: _pickOptionalUnit(root, const ['banner']),
      androidRewarded: _pickOptionalUnit(root, const ['rewarded']),
      androidInterstitial: _pickOptionalUnit(root, const ['interstitial']),
    );
  }
}
