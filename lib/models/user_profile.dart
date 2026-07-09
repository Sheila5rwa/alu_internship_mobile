class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String bio;
  final String skills;
  final String? startupId;
  final String githubLink;
  final String portfolioLink;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.bio,
    required this.skills,
    this.startupId,
    this.githubLink = '',
    this.portfolioLink = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'bio': bio,
      'skills': skills,
      'startupId': startupId,
      'githubLink': githubLink,
      'portfolioLink': portfolioLink,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      role: map['role'] as String,
      bio: map['bio'] as String? ?? '',
      skills: map['skills'] as String? ?? '',
      startupId: map['startupId'] as String?,
      githubLink: map['githubLink'] as String? ?? '',
      portfolioLink: map['portfolioLink'] as String? ?? '',
    );
  }
}
