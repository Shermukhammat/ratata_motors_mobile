import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

class AppState {
  final bool onboardingDone;
  final AuthStatus authStatus;

  const AppState({
    required this.onboardingDone,
    required this.authStatus,
  });

  AppState copyWith({
    bool? onboardingDone,
    AuthStatus? authStatus,
  }) {
    return AppState(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      authStatus: authStatus ?? this.authStatus,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  AppController()
      : super(const AppState(
    onboardingDone: false,
    authStatus: AuthStatus.loading,
  )) {
    _load();
  }

  Future<void> _load() async {
    // Simulate app startup work (later: SharedPreferences/token)
    await Future.delayed(const Duration(seconds: 5));

    // Example: onboarding not done + not logged in
    state = state.copyWith(
      onboardingDone: false,
      authStatus: AuthStatus.unauthenticated,
    );
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingDone: true);
  }

  void login() {
    state = state.copyWith(authStatus: AuthStatus.authenticated);
  }

  void logout() {
    state = state.copyWith(authStatus: AuthStatus.unauthenticated);
  }
}

final appControllerProvider = StateNotifierProvider<AppController, AppState>((ref) => AppController());
