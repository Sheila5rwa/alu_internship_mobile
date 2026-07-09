import '../models/application_model.dart';
import '../models/opportunity.dart';
import '../models/startup_profile.dart';
import '../models/user_profile.dart';

enum AuthStatus { initial, loading, unauthenticated, needsProfile, authenticated }

class AppState {
  final AuthStatus authStatus;
  final bool isLoading;
  final String? error;
  final UserProfile? currentProfile;
  final List<StartupProfile> startups;
  final List<Opportunity> opportunities;
  final List<ApplicationModel> applications;

  const AppState({
    this.authStatus = AuthStatus.initial,
    this.isLoading = false,
    this.error,
    this.currentProfile,
    this.startups = const [],
    this.opportunities = const [],
    this.applications = const [],
  });

  AppState copyWith({
    AuthStatus? authStatus,
    bool? isLoading,
    String? error,
    UserProfile? currentProfile,
    List<StartupProfile>? startups,
    List<Opportunity>? opportunities,
    List<ApplicationModel>? applications,
  }) {
    return AppState(
      authStatus: authStatus ?? this.authStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentProfile: currentProfile ?? this.currentProfile,
      startups: startups ?? this.startups,
      opportunities: opportunities ?? this.opportunities,
      applications: applications ?? this.applications,
    );
  }
}
