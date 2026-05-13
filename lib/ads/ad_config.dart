import 'dart:io';

/// Ad unit IDs are set only from remote JSON ([AdUnitsRemoteLoader]); nothing is bundled in-app.
abstract final class AdConfig {
  static String _bannerIos = '';
  static String _bannerAndroid = '';
  static String _interstitialIos = '';
  static String _interstitialAndroid = '';
  static String _rewardedIos = '';
  static String _rewardedAndroid = '';
  static String _appOpenIos = '';
  static String _appOpenAndroid = '';

  static bool isValidAdUnitId(String s) =>
      s.startsWith('ca-app-pub-') && s.contains('/');

  static String _sanitize(String? raw) {
    if (raw == null) return '';
    final t = raw.trim();
    if (t.isEmpty || t == '0') return '';
    if (!isValidAdUnitId(t)) return '';
    return t;
  }

  static String get bannerUnitId =>
      Platform.isIOS ? _bannerIos : _bannerAndroid;

  static String get interstitialUnitId =>
      Platform.isIOS ? _interstitialIos : _interstitialAndroid;

  static String get rewardedUnitId =>
      Platform.isIOS ? _rewardedIos : _rewardedAndroid;

  static String get appOpenUnitId =>
      Platform.isIOS ? _appOpenIos : _appOpenAndroid;

  static bool get hasBannerUnitId => bannerUnitId.isNotEmpty;
  static bool get hasInterstitialUnitId => interstitialUnitId.isNotEmpty;
  static bool get hasRewardedUnitId => rewardedUnitId.isNotEmpty;
  static bool get hasAppOpenUnitId => appOpenUnitId.isNotEmpty;

  /// Applies IDs from parsed remote JSON (see [AdUnitsRemoteLoader]).
  /// Use `0`, empty, or omit keys to disable a placement. Invalid strings are ignored (no ad).
  static void applyRemoteUnits({
    String? iosAppOpen,
    String? iosBanner,
    String? iosRewarded,
    String? iosInterstitial,
    String? androidAppOpen,
    String? androidBanner,
    String? androidRewarded,
    String? androidInterstitial,
  }) {
    _appOpenIos = _sanitize(iosAppOpen);
    _bannerIos = _sanitize(iosBanner);
    _rewardedIos = _sanitize(iosRewarded);
    _interstitialIos = _sanitize(iosInterstitial);
    _appOpenAndroid = _sanitize(androidAppOpen);
    _bannerAndroid = _sanitize(androidBanner);
    _rewardedAndroid = _sanitize(androidRewarded);
    _interstitialAndroid = _sanitize(androidInterstitial);
  }
}
