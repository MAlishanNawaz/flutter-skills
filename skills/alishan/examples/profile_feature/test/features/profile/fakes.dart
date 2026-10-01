import 'package:profile_feature_example/core/error/app_error.dart';
import 'package:profile_feature_example/core/error/result.dart';
import 'package:profile_feature_example/features/profile/data/profile_remote_source.dart';
import 'package:profile_feature_example/features/profile/domain/profile.dart';
import 'package:profile_feature_example/features/profile/domain/profile_repository.dart';

const ada = Profile(id: 'p1', firstName: 'Ada', lastName: 'Lovelace', email: 'ada@example.com');

/// In-memory fake: simpler and sturdier than a mock with `when(...)` chains.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.profile = ada, this.failWith});

  Profile profile;
  AppError? failWith;
  int updateCalls = 0;

  @override
  Future<Result<Profile>> getProfile(String id) async => failWith == null ? Ok(profile) : Err(failWith!);

  @override
  Future<Result<Profile>> updateName(String id, {required String firstName, required String lastName}) async {
    updateCalls++;
    await Future<void>.delayed(Duration.zero);
    if (failWith case final error?) return Err(error);
    return Ok(profile = profile.copyWith(firstName: firstName, lastName: lastName));
  }
}

class FakeRemoteSource implements ProfileRemoteSource {
  FakeRemoteSource({this.json = const {}, this.error});
  final Map<String, Object?> json;
  final Object? error;
  Map<String, Object?>? lastPatch;

  @override
  Future<Map<String, Object?>> fetch(String id) async {
    if (error case final e?) throw e;
    return json;
  }

  @override
  Future<Map<String, Object?>> patch(String id, Map<String, Object?> fields) async {
    if (error case final e?) throw e;
    lastPatch = fields;
    return {...json, ...fields};
  }
}
