class StartupProfile {
  final String id;
  final String ownerId;
  final String name;
  final String mission;
  final String sector;
  final String location;
  final String website;
  final bool isVerified;
  final DateTime createdAt;

  const StartupProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.mission,
    required this.sector,
    required this.location,
    required this.website,
    required this.isVerified,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'mission': mission,
      'sector': sector,
      'location': location,
      'website': website,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StartupProfile.fromMap(Map<String, dynamic> map) {
    return StartupProfile(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      mission: map['mission'] as String,
      sector: map['sector'] as String,
      location: map['location'] as String,
      website: map['website'] as String,
      isVerified: map['isVerified'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
