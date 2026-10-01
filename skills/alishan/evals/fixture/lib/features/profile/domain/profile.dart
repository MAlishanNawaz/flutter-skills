/// Immutable entity. No JSON, no Flutter, no SDK types.
final class Profile {
  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    this.photoUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;
  final String? photoUrl;

  Profile copyWith({String? firstName, String? lastName, String? bio, String? photoUrl}) => Profile(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email,
        bio: bio ?? this.bio,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.email == email &&
      other.bio == bio &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(id, firstName, lastName, email, bio, photoUrl);
}
