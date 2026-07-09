class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentBio;
  final String studentSkills;
  final String studentGithubLink;
  final String studentPortfolioLink;
  final String startupId;
  final String startupName;
  final String opportunityType;
  final String coverNote;
  final String status;
  final DateTime appliedAt;

  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentBio,
    required this.studentSkills,
    required this.studentGithubLink,
    required this.studentPortfolioLink,
    required this.startupId,
    required this.startupName,
    required this.opportunityType,
    required this.coverNote,
    required this.status,
    required this.appliedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentBio': studentBio,
      'studentSkills': studentSkills,
      'studentGithubLink': studentGithubLink,
      'studentPortfolioLink': studentPortfolioLink,
      'startupId': startupId,
      'startupName': startupName,
      'opportunityType': opportunityType,
      'coverNote': coverNote,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'] as String,
      opportunityId: map['opportunityId'] as String,
      opportunityTitle: map['opportunityTitle'] as String,
      studentId: map['studentId'] as String,
      studentName: map['studentName'] as String,
      studentEmail: map['studentEmail'] as String,
      studentBio: map['studentBio'] as String? ?? '',
      studentSkills: map['studentSkills'] as String? ?? '',
      studentGithubLink: map['studentGithubLink'] as String? ?? '',
      studentPortfolioLink: map['studentPortfolioLink'] as String? ?? '',
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      opportunityType: map['opportunityType'] as String? ?? 'Internship',
      coverNote: map['coverNote'] as String,
      status: map['status'] as String,
      appliedAt: DateTime.parse(map['appliedAt'] as String),
    );
  }
}
