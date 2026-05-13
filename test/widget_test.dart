import 'package:fc_app3_send_files_to_tv/screens/main_shell.dart';
import 'package:fc_app3_send_files_to_tv/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main shell shows Send files to TV in app bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const MainShell(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Send files to TV'), findsWidgets);
  });
}
