import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/application_model.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this._service) : super(const AppState()) {
    _listenToAuth();
  }

  final FirebaseService _service;

  void _listenToAuth() {
    _service.authStateChanges.listen((user) async {
      if (user == null) {
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated, isLoading: false));
        return;
      }

      emit(state.copyWith(authStatus: AuthStatus.loading, isLoading: true));
      final profile = await _service.getUserProfile(user.uid);
      if (profile == null) {
        emit(state.copyWith(
          authStatus: AuthStatus.needsProfile,
          isLoading: false,
          currentProfile: null,
        ));
      } else {
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          isLoading: false,
          currentProfile: profile,
        ));
      }
    });
  }

  Future<void> signUp({required String email, required String password, required String name, required String role}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final credential = await _service.signUpWithEmail(email: email, password: password);
      final profile = UserProfile(
        uid: credential.user!.uid,
        email: email,
        displayName: name,
        role: role,
        bio: '',
        skills: '',
      );
      await _service.saveUserProfile(profile);
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        isLoading: false,
        currentProfile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _service.signInWithEmail(email: email, password: password);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> completeProfile({required String name, required String bio, required String skills, required String role, String githubLink = '', String portfolioLink = ''}) async {
    final user = _service.currentUser;
    if (user == null) return;
    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: name,
      role: role,
      bio: bio,
      skills: skills,
      githubLink: githubLink,
      portfolioLink: portfolioLink,
    );
    await _service.saveUserProfile(profile);
    emit(state.copyWith(authStatus: AuthStatus.authenticated, currentProfile: profile));
  }

  Future<void> signOut() async {
    await _service.signOut();
    emit(state.copyWith(authStatus: AuthStatus.unauthenticated, currentProfile: null));
  }

  Future<void> createStartup({required StartupProfile startup}) async {
    await _service.createStartupProfile(startup);
    await refreshStartups();
  }

  Future<void> refreshStartups() async {
    // The stream is handled by the UI, but this placeholder keeps the cubit contract simple.
  }

  Future<void> createOpportunity({required Opportunity opportunity}) async {
    await _service.createOpportunity(opportunity);
  }

  Future<void> updateOpportunity({required Opportunity opportunity}) async {
    await _service.updateOpportunity(opportunity);
  }

  Future<void> deleteOpportunity({required String id}) async {
    await _service.deleteOpportunity(id);
  }

  Future<void> submitApplication({required ApplicationModel application}) async {
    await _service.submitApplication(application);
  }

  Future<void> updateApplicationStatus({required String applicationId, required String status}) async {
    await _service.updateApplicationStatus(applicationId: applicationId, status: status);
  }
}
