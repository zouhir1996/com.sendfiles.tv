import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Loads and shows AdMob app open, banner, rewarded, and interstitial ads.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  bool _loadingAppOpen = false;
  bool _showingFullScreen = false;
  DateTime? _lastAppOpenAt;
  int _coldStartFrames = 0;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: []),
      );
    }
    _initialized = true;
    if (AdConfig.hasRewardedUnitId) _preloadRewarded();
    if (AdConfig.hasInterstitialUnitId) _preloadInterstitial();
    if (AdConfig.hasAppOpenUnitId) _preloadAppOpen();
  }

  void onFirstFrame() {
    _coldStartFrames++;
  }

  Future<void> handleAppResumed() async {
    if (!_initialized || _showingFullScreen || !AdConfig.hasAppOpenUnitId) {
      return;
    }
    if (_coldStartFrames < 2) return;
    final last = _lastAppOpenAt;
    if (last != null && DateTime.now().difference(last) < const Duration(minutes: 4)) {
      return;
    }
    final ad = _appOpenAd;
    if (ad == null) {
      _preloadAppOpen();
      return;
    }
    _appOpenAd = null;
    _showingFullScreen = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _showingFullScreen = false;
        _lastAppOpenAt = DateTime.now();
        _preloadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _showingFullScreen = false;
        _preloadAppOpen();
      },
    );
    ad.show();
  }

  void _preloadRewarded() {
    if (!AdConfig.hasRewardedUnitId) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void _preloadInterstitial() {
    if (!AdConfig.hasInterstitialUnitId) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void _preloadAppOpen() {
    if (!AdConfig.hasAppOpenUnitId || _loadingAppOpen || _appOpenAd != null) {
      return;
    }
    _loadingAppOpen = true;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd?.dispose();
          _appOpenAd = ad;
          _loadingAppOpen = false;
        },
        onAdFailedToLoad: (_) {
          _loadingAppOpen = false;
        },
      ),
    );
  }

  /// Shows a rewarded ad if one is ready, then runs [afterDismissed]. If none is ready, runs [afterDismissed] immediately.
  Future<void> showRewardedThen(VoidCallback afterDismissed) async {
    await initialize();
    if (!AdConfig.hasRewardedUnitId) {
      afterDismissed();
      return;
    }
    final ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      afterDismissed();
      return;
    }
    _rewardedAd = null;
    final done = Completer<void>();
    _showingFullScreen = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _showingFullScreen = false;
        if (!done.isCompleted) done.complete();
        _preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _showingFullScreen = false;
        if (!done.isCompleted) done.complete();
        _preloadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) {});
    await done.future;
    afterDismissed();
  }

  /// Shows an interstitial if loaded; otherwise preloads for next time.
  Future<void> showInterstitialIfReady() async {
    await initialize();
    if (!AdConfig.hasInterstitialUnitId) return;
    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }
    _interstitialAd = null;
    final done = Completer<void>();
    _showingFullScreen = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _showingFullScreen = false;
        if (!done.isCompleted) done.complete();
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _showingFullScreen = false;
        if (!done.isCompleted) done.complete();
        _preloadInterstitial();
      },
    );
    ad.show();
    await done.future;
  }
}

/// Wraps the app to forward lifecycle events for app open ads.
class AppOpenLifecycleObserver extends StatefulWidget {
  const AppOpenLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  State<AppOpenLifecycleObserver> createState() => _AppOpenLifecycleObserverState();
}

class _AppOpenLifecycleObserverState extends State<AppOpenLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.onFirstFrame();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdService.instance.onFirstFrame();
      unawaited(AdService.instance.handleAppResumed());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
