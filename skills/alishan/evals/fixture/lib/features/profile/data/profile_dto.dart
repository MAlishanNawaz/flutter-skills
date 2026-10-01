import '../domain/profile.dart';

/// The wire shape. Stays inside the data layer; mapped to [Profile] before leaving it.
final class ProfileDto {
  const ProfileDto({required this.id, this.firstName, this.lastName, this.email, this.bio, this.photoUrl});

  factory ProfileDto.fromJson(Map<String, Object?> json) => ProfileDto(
        id: json['id'] as String,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        email: json['email'] as String?,
        bio: json['bio'] as String?,
        photoUrl: json['photo_url'] as String?,
      );

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? bio;
  final String? photoUrl;

  /// Nullable wire fields become safe defaults here, once, instead of `!` all over the UI.
  Profile toEntity() => Profile(
        id: id,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        email: email ?? '',
        bio: bio,
        photoUrl: photoUrl,
      );
}
