enum AuthProviderType { email, phone, google, unknown }

class UserEntity {
  const UserEntity({
    required this.id,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.providerType = AuthProviderType.unknown,
  });

  final String id;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final AuthProviderType providerType;

  String get firstName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim().split(' ').first;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      return phoneNumber!;
    }
    return 'Athlete';
  }

  String get providerDisplayName {
    switch (providerType) {
      case AuthProviderType.email:
        return 'Email & Password';
      case AuthProviderType.phone:
        return 'Phone Number';
      case AuthProviderType.google:
        return 'Google Sign-In';
      case AuthProviderType.unknown:
        return 'Firebase Auth';
    }
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    AuthProviderType? providerType,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      providerType: providerType ?? this.providerType,
    );
  }
}
