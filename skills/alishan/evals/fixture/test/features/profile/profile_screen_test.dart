import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/core/error/app_error.dart';
import 'package:sample_app/features/profile/presentation/profile_cubit.dart';
import 'package:sample_app/features/profile/presentation/profile_screen.dart';

import 'fakes.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  FakeProfileRepository repo, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: BlocProvider(
        create: (_) => ProfileCubit(repo, profileId: 'p1')..load(),
        child: const ProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the profile and completion', (tester) async {
    await pumpScreen(tester, FakeProfileRepository());
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
  });

  testWidgets('error state retries', (tester) async {
    final repo = FakeProfileRepository(failWith: const NetworkError());
    await pumpScreen(tester, repo);
    expect(find.textContaining('No connection'), findsOneWidget);

    repo.failWith = null;
    await tester.tap(find.text(ProfileStrings.retry));
    await tester.pumpAndSettle();
    expect(find.text('Ada Lovelace'), findsOneWidget);
  });

  for (final size in const [Size(320, 568), Size(400, 900), Size(1280, 800)]) {
    testWidgets('no overflow at $size and 2x text', (tester) async {
      await pumpScreen(tester, FakeProfileRepository(), size: size, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, FakeProfileRepository(failWith: const NetworkError()));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
