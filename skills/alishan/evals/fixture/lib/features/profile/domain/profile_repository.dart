import '../../../core/error/result.dart';
import 'profile.dart';

/// The domain owns the interface; the data layer implements it.
abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile(String id);
  Future<Result<Profile>> updateName(String id, {required String firstName, required String lastName});
}
