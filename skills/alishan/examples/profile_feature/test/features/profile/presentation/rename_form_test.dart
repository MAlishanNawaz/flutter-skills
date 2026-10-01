import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_feature_example/features/profile/presentation/profile_cubit.dart';
import 'package:profile_feature_example/features/profile/presentation/widgets/rename_form.dart';

import '../../../support/harness.dart';
import '../fakes.dart';

Future<FakeProfileRepository> pumpForm(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
}) async {
  final repo = FakeProfileRepository();
  final cubit = ProfileCubit(repo, profileId: 'p1');
  await cubit.load();
  await pumpAt(
    tester,
    BlocProvider.value(
      value: cubit,
      child:
          const Scaffold(body: SingleChildScrollView(child: RenameForm(initialFirst: 'Ada', initialLast: 'Lovelace'))),
    ),
    size: size,
    textScale: scale,
  );
  return repo;
}

void main() {
  testWidgets('two taps in the same frame save once', (tester) async {
    final repo = await pumpForm(tester);
    await tester.tap(find.text(RenameStrings.save));
    await tester.tap(find.text(RenameStrings.save)); // no pump between: same frame
    await tester.pumpAndSettle();
    expect(repo.updateCalls, 1);
  });

  testWidgets('no error while typing before the first submit', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.pump();
    expect(find.text(RenameStrings.required), findsNothing);

    await tester.tap(find.text(RenameStrings.save));
    await tester.pump();
    expect(find.text(RenameStrings.required), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Augusta');
    await tester.pump();
    expect(find.text(RenameStrings.required), findsNothing); // clears live once shown
  });

  for (final size in testSizes) {
    testWidgets('fits at $size with 2x text', (tester) async {
      await pumpForm(tester, size: size, scale: 2);
      expect(tester.takeException(), isNull);
    });
  }
}
