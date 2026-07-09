import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/application_model.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  Future<void> createStartupProfile(StartupProfile startup) async {
    await _firestore.collection('startups').doc(startup.id).set(startup.toMap());
  }

  Stream<List<StartupProfile>> streamStartups() {
    return _firestore
        .collection('startups')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StartupProfile.fromMap(doc.data()))
            .toList());
  }

  Stream<List<Opportunity>> streamOpportunities() {
    return _firestore
        .collection('opportunities')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Opportunity.fromMap(doc.data()))
            .toList());
  }

  Stream<List<Opportunity>> streamMyOpportunities(String startupId) {
    return _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Opportunity.fromMap(doc.data()))
            .toList());
  }

  Future<void> createOpportunity(Opportunity opportunity) async {
    await _firestore.collection('opportunities').doc(opportunity.id).set(opportunity.toMap());
  }

  Future<void> updateOpportunity(Opportunity opportunity) async {
    await _firestore.collection('opportunities').doc(opportunity.id).update(opportunity.toMap());
  }

  Future<void> deleteOpportunity(String id) async {
    await _firestore.collection('opportunities').doc(id).delete();
  }

  Future<String> submitApplication(ApplicationModel application) async {
    final id = _uuid.v4();
    final applicationWithId = ApplicationModel(
      id: id,
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      studentId: application.studentId,
      studentName: application.studentName,
      studentEmail: application.studentEmail,
      studentBio: application.studentBio,
      studentSkills: application.studentSkills,
      studentGithubLink: application.studentGithubLink,
      studentPortfolioLink: application.studentPortfolioLink,
      startupId: application.startupId,
      startupName: application.startupName,
      opportunityType: application.opportunityType,
      coverNote: application.coverNote,
      status: application.status,
      appliedAt: application.appliedAt,
    );
    await _firestore.collection('applications').doc(id).set(applicationWithId.toMap());
    return id;
  }

  Stream<List<ApplicationModel>> streamMyApplications(String studentId) {
    return _firestore
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ApplicationModel>> streamApplicationsForOpportunity(String opportunityId) {
    return _firestore
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> updateApplicationStatus({required String applicationId, required String status}) async {
    await _firestore.collection('applications').doc(applicationId).update({'status': status});
  }

  Future<StartupProfile?> getStartupByOwner(String ownerId) async {
    final snapshot = await _firestore
        .collection('startups')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return StartupProfile.fromMap(snapshot.docs.first.data());
  }
}
