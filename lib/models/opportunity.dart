class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String role;
  final String category;
  final String location;
  final String duration;
  final String stipend;
  final String opportunityType;
  final List<String> skills;
  final bool isActive;
  final DateTime createdAt;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.role,
    required this.category,
    required this.location,
    required this.duration,
    required this.stipend,
    required this.opportunityType,
    required this.skills,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'role': role,
      'category': category,
      'location': location,
      'duration': duration,
      'stipend': stipend,
      'opportunityType': opportunityType,
      'skills': skills,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Opportunity.fromMap(Map<String, dynamic> map) {
    return Opportunity(
      id: map['id'] as String,
      startupId: map['startupId'] as String,
      startupName: map['startupName'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      role: map['role'] as String,
      category: map['category'] as String,
      location: map['location'] as String,
      duration: map['duration'] as String,
      stipend: map['stipend'] as String,
      opportunityType: map['opportunityType'] as String? ?? 'Internship',
      skills: List<String>.from(map['skills'] as List<dynamic>),
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
