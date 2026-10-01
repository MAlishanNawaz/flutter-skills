import 'dart:io';

import '../../../core/error/app_error.dart';
import '../../../core/error/result.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import 'profile_dto.dart';
import 'profile_remote_source.dart';

final class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);
  final ProfileRemoteSource _remote;

  @override
  Future<Result<Profile>> getProfile(String id) =>
      _guard(() async => ProfileDto.fromJson(await _remote.fetch(id)).toEntity());

  @override
  Future<Result<Profile>> updateName(String id, {required String firstName, required String lastName}) => _guard(
        () async => ProfileDto.fromJson(
          await _remote.patch(id, {'first_name': firstName.trim(), 'last_name': lastName.trim()}),
        ).toEntity(),
      );

  /// The one place exceptions become [AppError]s.
  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok(await run());
    } on ApiException catch (e) {
      return Err(_fromApi(e));
    } on SocketException {
      return const Err(NetworkError());
    } catch (e) {
      return Err(UnknownError(e));
    }
  }

  AppError _fromApi(ApiException e) => switch (e.statusCode) {
        401 || 403 => const UnauthorisedError(),
        404 => const NotFoundError(),
        422 => ValidationError({
            for (final MapEntry(:key, :value) in (e.body['errors'] as Map<String, Object?>? ?? const {}).entries)
              key: '$value',
          }),
        _ => UnknownError(e),
      };
}
