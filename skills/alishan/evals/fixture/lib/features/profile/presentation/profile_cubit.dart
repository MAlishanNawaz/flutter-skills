import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo, {required this.profileId}) : super(const ProfileLoading());

  final ProfileRepository _repo; // interface — tests pass a fake
  final String profileId;

  Future<void> load() async {
    emit(const ProfileLoading());
    final result = await _repo.getProfile(profileId);
    if (isClosed) return;
    emit(result.fold(ProfileFailed.new, ProfileLoaded.new));
  }

  Future<void> rename({required String firstName, required String lastName}) async {
    final current = state;
    if (current is! ProfileLoaded || current.saving) return; // drops double taps

    emit(ProfileLoaded(current.profile, saving: true));
    final result = await _repo.updateName(profileId, firstName: firstName, lastName: lastName);
    if (isClosed) return;
    emit(
      result.fold(
        (error) => ProfileLoaded(current.profile, saveError: error), // keep what's on screen
        ProfileLoaded.new,
      ),
    );
  }
}
