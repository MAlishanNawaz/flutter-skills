import '../../../core/error/app_error.dart';
import '../domain/profile.dart';

/// Only valid states exist; `switch` over them is exhaustive.
sealed class ProfileState {
  const ProfileState();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile, {this.saving = false, this.saveError});
  final Profile profile;
  final bool saving;
  final AppError? saveError;
}

final class ProfileFailed extends ProfileState {
  const ProfileFailed(this.error);
  final AppError error;
}
