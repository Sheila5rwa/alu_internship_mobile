import 'package:flutter_test/flutter_test.dart';

import 'package:aluinternship/models/user_profile.dart';
import 'package:aluinternship/models/startup_profile.dart';
import 'package:aluinternship/models/application_model.dart';

void main() {
  group('Ecosystem Model Tests', () {
    test('UserProfile serialization handles bookmarks', () {
      final user = UserProfile(
        uid: 'student-99',
        email: 'student@alueducation.com',
        displayName: 'John Doe',
        role: 'student',
        bio: 'Flutter Enthusiast',
        skills: 'Flutter, Dart, Firebase',
        bookmarkedOpportunityIds: ['opp-1', 'opp-2'],
      );

      final map = user.toMap();
      expect(map['bookmarkedOpportunityIds'], containsAll(['opp-1', 'opp-2']));

      final parsed = UserProfile.fromMap(map);
      expect(parsed.uid, 'student-99');
      expect(parsed.bookmarkedOpportunityIds, containsAll(['opp-1', 'opp-2']));
    });

    test('StartupProfile serialization handles verification status and regCode', () {
      final startup = StartupProfile(
        id: 'startup-88',
        ownerId: 'owner-77',
        name: 'EcoVentures',
        mission: 'Creating green solutions',
        sector: 'CleanTech',
        location: 'Kigali Campus',
        website: 'https://ecoventures.rw',
        isVerified: true,
        status: 'Approved',
        regCode: 'ALU-GRP-2026-99',
        createdAt: DateTime(2026, 7, 9),
      );

      final map = startup.toMap();
      expect(map['status'], 'Approved');
      expect(map['regCode'], 'ALU-GRP-2026-99');
      expect(map['isVerified'], true);

      final parsed = StartupProfile.fromMap(map);
      expect(parsed.id, 'startup-88');
      expect(parsed.status, 'Approved');
      expect(parsed.regCode, 'ALU-GRP-2026-99');
      expect(parsed.isVerified, true);
    });

    test('ApplicationModel supports interview scheduling details', () {
      final app = ApplicationModel(
        id: 'app-50',
        opportunityId: 'opp-1',
        opportunityTitle: 'Frontend Intern',
        studentId: 'student-99',
        studentName: 'John Doe',
        studentEmail: 'student@alueducation.com',
        studentBio: 'Developer bio',
        studentSkills: 'Flutter',
        studentGithubLink: '',
        studentPortfolioLink: '',
        startupId: 'startup-88',
        startupName: 'EcoVentures',
        opportunityType: 'Internship',
        coverNote: 'Excited to join',
        status: 'Interview Scheduled',
        appliedAt: DateTime(2026, 7, 9),
        interviewDate: '2026-07-15',
        interviewTime: '10:00 AM',
        interviewLink: 'https://meet.google.com/xyz',
        interviewNotes: 'Prepare portfolio slides',
      );

      final map = app.toMap();
      expect(map['interviewDate'], '2026-07-15');
      expect(map['interviewLink'], 'https://meet.google.com/xyz');

      final parsed = ApplicationModel.fromMap(map);
      expect(parsed.id, 'app-50');
      expect(parsed.interviewDate, '2026-07-15');
      expect(parsed.interviewTime, '10:00 AM');
      expect(parsed.interviewLink, 'https://meet.google.com/xyz');
      expect(parsed.interviewNotes, 'Prepare portfolio slides');
    });
  });
}
