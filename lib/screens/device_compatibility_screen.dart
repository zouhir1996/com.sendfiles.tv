import 'package:flutter/material.dart';

class DeviceCompatibilityScreen extends StatelessWidget {
  const DeviceCompatibilityScreen({super.key});

  static const _disclaimer =
      'These notes are general guidance for streaming and casting from an iPhone '
      'or iPad. Capabilities depend on exact model year, region, firmware, and '
      'which apps you use—always confirm in your TV’s settings and the app’s help.';

  static const _rows = <_DeviceRow>[
    _DeviceRow(
      'Apple TV (HD / 4K / 4K 2nd gen)',
      'Usually the smoothest AirPlay target',
      'Prefer AirPlay from inside supported video apps for best quality; mirroring '
      'is heavier on Wi‑Fi. Ethernet on the Apple TV helps with large or high‑bitrate files.',
    ),
    _DeviceRow(
      'Samsung smart TV (recent years)',
      'AirPlay on many models; check settings',
      'Look for AirPlay under General → Apple AirPlay Settings. Casting from '
      'individual apps varies—use each app’s Cast or AirPlay button when available.',
    ),
    _DeviceRow(
      'LG webOS TV',
      'AirPlay supported on many sets; webOS version matters',
      'Enable Apple AirPlay in Connection settings if offered. For local media, '
      'LG’s apps or a DLNA server on your network are common alternatives.',
    ),
    _DeviceRow(
      'Chromecast with Google TV',
      'Great for Cast‑enabled streaming apps',
      'Open a Cast‑enabled app (for example YouTube or Netflix), tap Cast, and '
      'pick the Chromecast. Playing arbitrary local files from iOS usually needs a '
      'compatible third‑party app that explicitly supports casting.',
    ),
    _DeviceRow(
      'Roku (Ultra, Streaming Stick 4K, select TVs)',
      'AirPlay 2 on many current devices',
      'Under Settings → Apple AirPlay and HomeKit, enable AirPlay if you do not '
      'see your Roku from Control Center. Performance still depends on Wi‑Fi quality.',
    ),
    _DeviceRow(
      'Amazon Fire TV',
      'No built‑in AirPlay; plan around apps or HDMI',
      'Expect to use supported apps, manufacturer mobile apps, or a wired HDMI '
      'adapter from your phone instead of first‑party AirPlay.',
    ),
    _DeviceRow(
      'Sony Bravia (Google TV / Android TV)',
      'Chromecast built‑in is common; some models add AirPlay',
      'Check your model’s specs for AirPlay. For Chromecast, use Cast inside '
      'supported apps on the same Wi‑Fi network.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device compatibility')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            _disclaimer,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.45,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _DeviceCard(row: _rows[i]),
          ],
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.row});

  final _DeviceRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              row.summary,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              row.detail,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceRow {
  const _DeviceRow(this.name, this.summary, this.detail);

  final String name;
  final String summary;
  final String detail;
}
