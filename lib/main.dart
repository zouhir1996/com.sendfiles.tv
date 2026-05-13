import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads/ad_service.dart';
import 'ads/ad_units_remote_loader.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdUnitsRemoteLoader.load();
  await AdService.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  bootstrapApp(prefs);
}
