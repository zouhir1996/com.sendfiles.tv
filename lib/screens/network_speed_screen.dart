import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NetworkSpeedScreen extends StatefulWidget {
  const NetworkSpeedScreen({super.key});

  @override
  State<NetworkSpeedScreen> createState() => _NetworkSpeedScreenState();
}

class _NetworkSpeedScreenState extends State<NetworkSpeedScreen> {
  bool _running = false;
  double? _mbps;
  int? _latencyMs;
  String? _note;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _mbps = null;
      _latencyMs = null;
      _note = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final rnd = math.Random();
    setState(() {
      _mbps = 35 + rnd.nextDouble() * 165;
      _latencyMs = 8 + rnd.nextInt(35);
      _note =
          'These numbers are randomly generated examples for planning—they do not '
          'measure your Wi‑Fi or internet. On iPhone, use Settings → Wi‑Fi (tap '
          'the “i” next to your network) for basic link info, your router’s app '
          'for signal quality, or a dedicated speed-test app or website when you '
          'need a real throughput reading.';
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network planner')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Example throughput & latency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This screen does not run a network test. It shows sample Mbps and '
              'latency values you can plug into the transfer calculator to see how '
              'different link speeds feel for large files.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 28),
            if (_running)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.accentCyan),
                ),
              )
            else if (_mbps != null) ...[
              _MetricTile(
                label: 'Example throughput (not measured)',
                value: '${_mbps!.toStringAsFixed(1)} Mb/s',
              ),
              const SizedBox(height: 12),
              _MetricTile(
                label: 'Example latency (not measured)',
                value: '$_latencyMs ms',
              ),
              const SizedBox(height: 16),
              Text(
                _note ?? '',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: _running ? null : _run,
              child: Text(_mbps == null ? 'Generate examples' : 'New examples'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252842),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accentCyan,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
