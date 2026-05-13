import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TransferCalculatorScreen extends StatefulWidget {
  const TransferCalculatorScreen({super.key});

  @override
  State<TransferCalculatorScreen> createState() => _TransferCalculatorScreenState();
}

class _TransferCalculatorScreenState extends State<TransferCalculatorScreen> {
  double _gigabytes = 4;
  double _mbps = 80;

  @override
  Widget build(BuildContext context) {
    // Decimal GB (10⁹ bytes) and decimal Mbps (10⁶ bits/s): seconds ≈ GB × 8000 / Mbps.
    final seconds = (_gigabytes * 8000) / _mbps;
    final duration = Duration(seconds: seconds.round().clamp(1, 8640000));
    final pretty = _formatDuration(duration);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer calculator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Rough estimate for a single large file over a steady link. Uses '
            'decimal gigabytes (1 GB = 10⁹ bytes) and megabits per second (Mb/s). '
            'Real transfers are often slower due to protocol overhead, encryption, '
            'disk speed, Wi‑Fi contention, and read/write on both ends.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 24),
          Text(
            'File size: ${_gigabytes.toStringAsFixed(1)} GB',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _gigabytes,
            min: 0.5,
            max: 64,
            divisions: 127,
            label: '${_gigabytes.toStringAsFixed(1)} GB',
            onChanged: (v) => setState(() => _gigabytes = v),
          ),
          const SizedBox(height: 8),
          Text(
            'Link speed: ${_mbps.round()} Mb/s',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _mbps,
            min: 10,
            max: 500,
            divisions: 49,
            label: '${_mbps.round()} Mb/s',
            onChanged: (v) => setState(() => _mbps = v),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF252842),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated transfer time',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  pretty,
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Idealized: seconds ≈ GB × 8000 ÷ Mb/s (decimal GB and Mb/s).',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 48) {
      return '${d.inDays} days ${d.inHours.remainder(24)} h';
    }
    if (d.inHours >= 1) {
      return '${d.inHours} h ${d.inMinutes.remainder(60)} min';
    }
    if (d.inMinutes >= 1) {
      return '${d.inMinutes} min ${d.inSeconds.remainder(60)} s';
    }
    return '${d.inSeconds} s';
  }
}
