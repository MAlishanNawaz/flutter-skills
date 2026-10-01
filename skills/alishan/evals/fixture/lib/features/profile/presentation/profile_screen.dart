import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design/tokens.dart';
import '../../../core/error/app_error.dart';
import '../domain/profile.dart';
import '../domain/profile_rules.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';
import 'widgets/profile_completion_card.dart';

/// Copy lives in one place (swap for AppLocalizations / the project's strings class).
abstract final class ProfileStrings {
  static const title = 'Profile';
  static const completion = 'Profile completion';
  static const retry = 'Try again';
  static const saveFailed = "Couldn't save your changes.";

  static String error(AppError e) => switch (e) {
        NetworkError() => 'No connection. Check your internet and try again.',
        NotFoundError() => "We couldn't find this profile.",
        UnauthorisedError() => 'Please sign in again.',
        ValidationError() => 'Some details need fixing.',
        UnknownError() => 'Something went wrong.',
      };
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(ProfileStrings.title)),
        // Side effects go in a listener, never in build.
        body: BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (prev, next) => next is ProfileLoaded && next.saveError != null,
          listener: (context, _) =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ProfileStrings.saveFailed))),
          child: SafeArea(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) => switch (state) {
                ProfileLoading() => const _ProfileSkeleton(),
                ProfileFailed(:final error) => _ProfileError(
                    message: ProfileStrings.error(error),
                    onRetry: context.read<ProfileCubit>().load,
                  ),
                ProfileLoaded(:final profile) => _ProfileBody(profile: profile),
              },
            ),
          ),
        ),
      );
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // narrow column on web/tablet
          child: ListView(
            padding: const EdgeInsets.all(Spacing.xl),
            children: [
              Text(displayName(profile), style: AppText.heading),
              const SizedBox(height: Spacing.xs),
              Text(profile.email, style: AppText.bodySmall),
              const SizedBox(height: Spacing.xl),
              ProfileCompletionCard(percent: completionPercent(profile), label: ProfileStrings.completion),
            ],
          ),
        ),
      );
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Loading profile',
        child: ListView(
          padding: const EdgeInsets.all(Spacing.xl),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _Bone(width: 180, height: 22),
            SizedBox(height: Spacing.sm),
            _Bone(width: 220, height: 16),
            SizedBox(height: Spacing.xl),
            _Bone(height: 96),
          ],
        ),
      );
}

class _Bone extends StatelessWidget {
  const _Bone({this.width, required this.height});
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(Radii.card)),
        ),
      );
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(height: Spacing.sm),
              Text(message, style: AppText.base, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.lg),
              FilledButton(onPressed: onRetry, child: const Text(ProfileStrings.retry)),
            ],
          ),
        ),
      );
}
