import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sizes worth testing: smallest phone, a common phone, and a typical clamped web column.
const testSizes = [Size(320, 568), Size(390, 844), Size(400, 900)];

/// Pumps [child] at a real size and text scale. Wrap it in the parents it has in the app
/// (theme, providers, scroll/padding), or overflow results won't match the device.
///
/// Fonts: `flutter test` renders in Ahem (every glyph a full square), so text measures wider than
/// on a device. If the app bundles a font, load it with `FontLoader` in `setUpAll`; this example
/// bundles none, so a pass here is strict and a failure may be a false alarm.
Future<void> pumpAt(WidgetTester tester, Widget child, {Size size = const Size(390, 844), double textScale = 1}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}
