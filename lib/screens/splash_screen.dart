import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/sfttv_logo.dart';

typedef SplashFinished = void Function(BuildContext context);

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  final SplashFinished onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      widget.onFinished(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: const Center(
        child: SfttvLogo(size: 132),
      ),
    );
  }
}
