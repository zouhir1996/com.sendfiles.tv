import 'package:flutter/material.dart';

import 'ad_service.dart';

/// Rewarded ad, then push [page]; when the route is popped, show an interstitial.
Future<void> pushToolRoute(BuildContext context, Widget page) async {
  await AdService.instance.showRewardedThen(() {});
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  if (context.mounted) {
    await AdService.instance.showInterstitialIfReady();
  }
}
