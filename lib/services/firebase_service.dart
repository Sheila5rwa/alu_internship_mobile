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
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Opportunity.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<Opportunity>> streamMyOpportunities(String startupId) {
    return _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Opportunity.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
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
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return list;
        });
  }

  Stream<List<ApplicationModel>> streamApplicationsForOpportunity(String opportunityId) {
    return _firestore
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return list;
        });
  }

  Stream<List<ApplicationModel>> streamApplicationsForStartup(String startupId) {
    return _firestore
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return list;
        });
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

  Stream<StartupProfile?> streamStartupByOwner(String ownerId) {
    return _firestore
        .collection('startups')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return StartupProfile.fromMap(snapshot.docs.first.data());
        });
  }

  Future<void> toggleBookmark(String userId, String opportunityId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final doc = await userRef.get();
    if (!doc.exists) return;
    final currentBookmarks = List<String>.from(doc.data()?['bookmarkedOpportunityIds'] ?? []);
    if (currentBookmarks.contains(opportunityId)) {
      currentBookmarks.remove(opportunityId);
    } else {
      currentBookmarks.add(opportunityId);
    }
    await userRef.update({'bookmarkedOpportunityIds': currentBookmarks});
  }

  Stream<List<Map<String, dynamic>>> streamMyChats(String userId, String role) {
    final field = role == 'student' ? 'studentId' : 'startupId';
    return _firestore
        .collection('chats')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    required String studentId,
    required String studentName,
    required String startupId,
    required String startupName,
  }) async {
    final now = DateTime.now();
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    await chatRef.set({
      'id': chatId,
      'studentId': studentId,
      'studentName': studentName,
      'startupId': startupId,
      'startupName': startupName,
      'lastMessage': content,
      'lastMessageAt': now.toIso8601String(),
    }, SetOptions(merge: true));
    
    final msgId = _uuid.v4();
    await chatRef.collection('messages').doc(msgId).set({
      'id': msgId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'sentAt': now.toIso8601String(),
    });
  }

  Future<void> simulateStartupVerification(String startupId, String newStatus) async {
    await _firestore.collection('startups').doc(startupId).update({
      'status': newStatus,
      'isVerified': newStatus == 'Approved',
    });
  }

  Future<void> scheduleInterview({
    required String applicationId,
    required String date,
    required String time,
    required String link,
    required String notes,
  }) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': 'Interview Scheduled',
      'interviewDate': date,
      'interviewTime': time,
      'interviewLink': link,
      'interviewNotes': notes,
    });
  }
}
