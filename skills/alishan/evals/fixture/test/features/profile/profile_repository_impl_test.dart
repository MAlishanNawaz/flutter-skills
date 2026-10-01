import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/core/error/app_error.dart';
import 'package:sample_app/core/error/result.dart';
import 'package:sample_app/features/profile/data/profile_remote_source.dart';
import 'package:sample_app/features/profile/data/profile_repository_impl.dart';
import 'package:sample_app/features/profile/domain/profile.dart';

import 'fakes.dart';

void main() {
  test('maps the DTO, defaulting missing fields', () async {
    final repo = ProfileRepositoryImpl(FakeRemoteSource(json: {'id': 'p1', 'first_name': 'Ada'}));
    final result = await repo.getProfile('p1');
    expect(result, isA<Ok<Profile>>());
    final profile = (result as Ok<Profile>).value;
    expect(profile.firstName, 'Ada');
    expect(profile.lastName, '');
  });

  test('trims names before sending', () async {
    final remote = FakeRemoteSource(json: {'id': 'p1'});
    await ProfileRepositoryImpl(remote).updateName('p1', firstName: ' Ada ', lastName: 'Lovelace ');
    expect(remote.lastPatch, {'first_name': 'Ada', 'last_name': 'Lovelace'});
  });

  Future<AppError> errorFor(Object thrown) async {
    final result = await ProfileRepositoryImpl(FakeRemoteSource(error: thrown)).getProfile('p1');
    return (result as Err<Profile>).error;
  }

  test('translates failures into AppError', () async {
    expect(await errorFor(const SocketException('offline')), isA<NetworkError>());
    expect(await errorFor(const ApiException(404)), isA<NotFoundError>());
    expect(await errorFor(const ApiException(401)), isA<UnauthorisedError>());
    expect(await errorFor(StateError('boom')), isA<UnknownError>());

    final validation = await errorFor(
      const ApiException(422, {
        'errors': {'first_name': 'Too long'},
      }),
    );
    expect((validation as ValidationError).fieldErrors, {'first_name': 'Too long'});
  });
}
