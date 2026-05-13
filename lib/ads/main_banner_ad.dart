import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_service.dart';

/// Adaptive banner fixed above the bottom navigation bar.
class MainBannerAd extends StatefulWidget {
  const MainBannerAd({super.key});

  @override
  State<MainBannerAd> createState() => _MainBannerAdState();
}

class _MainBannerAdState extends State<MainBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  AdSize? _size;
  bool _loadStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadBanner());
    });
  }

  Future<void> _loadBanner() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await AdService.instance.initialize();
    if (!mounted || !AdConfig.hasBannerUnitId) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;

    final banner = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
        },
      ),
    );

    _banner?.dispose();
    _banner = banner;
    _size = size;
    setState(() => _loaded = false);
    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_banner == null || _size == null || !_loaded) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _size!.width.toDouble(),
      height: _size!.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
