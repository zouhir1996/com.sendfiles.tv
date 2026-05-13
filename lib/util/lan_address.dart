import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

/// Best-effort Wi‑Fi / LAN IPv4 for URLs shown to the user.
Future<String?> resolveLanIPv4() async {
  try {
    final wifiIp = await NetworkInfo().getWifiIP();
    if (wifiIp != null &&
        wifiIp.isNotEmpty &&
        wifiIp != '0.0.0.0' &&
        _isLikelyLan(wifiIp)) {
      return wifiIp;
    }
  } catch (_) {
    // Continue to interface scan.
  }

  try {
    for (final iface in await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    )) {
      for (final addr in iface.addresses) {
        if (addr.isLoopback) continue;
        if (_isLikelyLan(addr.address)) return addr.address;
      }
    }
  } catch (_) {
    return null;
  }
  return null;
}

bool _isLikelyLan(String ip) {
  final parts = ip.split('.');
  if (parts.length != 4) return false;
  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);
  if (a == null || b == null) return false;
  if (a == 10) return true;
  if (a == 192 && b == 168) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  if (a == 169 && b == 254) return true;
  return false;
}
