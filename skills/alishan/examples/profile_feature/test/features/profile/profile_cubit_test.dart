import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_feature_example/core/error/app_error.dart';
import 'package:profile_feature_example/features/profile/presentation/profile_cubit.dart';
import 'package:profile_feature_example/features/profile/presentation/profile_state.dart';

import 'fakes.dart';

void main() {
  blocTest<ProfileCubit, ProfileState>(
    'load emits Loading then Loaded',
    build: () => ProfileCubit(FakeProfileRepository(), profileId: 'p1'),
    act: (c) => c.load(),
    expect: () => [
      isA<ProfileLoading>(),
      isA<ProfileLoaded>().having((s) => s.profile, 'profile', ada),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'load emits Failed with the AppError',
    build: () => ProfileCubit(FakeProfileRepository(failWith: const NetworkError()), profileId: 'p1'),
    act: (c) => c.load(),
    expect: () => [isA<ProfileLoading>(), isA<ProfileFailed>().having((s) => s.error, 'error', isA<NetworkError>())],
  );

  final repo = FakeProfileRepository();
  blocTest<ProfileCubit, ProfileState>(
    'rename ignores a double tap while saving',
    build: () => ProfileCubit(repo, profileId: 'p1'),
    seed: () => const ProfileLoaded(ada),
    act: (c) async {
      final first = c.rename(firstName: 'Augusta', lastName: 'King');
      await c.rename(firstName: 'Augusta', lastName: 'King');
      await first;
    },
    expect: () => [
      isA<ProfileLoaded>().having((s) => s.saving, 'saving', true),
      isA<ProfileLoaded>().having((s) => s.profile.firstName, 'firstName', 'Augusta'),
    ],
    verify: (_) => expect(repo.updateCalls, 1),
  );

  blocTest<ProfileCubit, ProfileState>(
    'failed rename keeps the old profile and reports the error',
    build: () => ProfileCubit(FakeProfileRepository(failWith: const NetworkError()), profileId: 'p1'),
    seed: () => const ProfileLoaded(ada),
    act: (c) => c.rename(firstName: 'X', lastName: 'Y'),
    expect: () => [
      isA<ProfileLoaded>().having((s) => s.saving, 'saving', true),
      isA<ProfileLoaded>()
          .having((s) => s.profile, 'profile', ada)
          .having((s) => s.saveError, 'saveError', isA<NetworkError>()),
    ],
  );
}
