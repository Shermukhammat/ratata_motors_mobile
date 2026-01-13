import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratata_motors/auth/onborading.dart';
import 'package:ratata_motors/auth/main.dart';
import 'package:ratata_motors/state/app_state.dart';
import 'package:ratata_motors/core/splash.dart';


class RootPage extends ConsumerWidget{
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);
    if (appState.authStatus == AuthStatus.loading) {
      return const SplashPage();
    }
    else if (appState.onboardingDone == false){
      return const OnboardingPage();
    }
    else if (appState.authStatus == AuthStatus.unauthenticated) {
      return LoginPage();
    }

    return const Scaffold(
      body: Center(child: Text("Welcome to Ratata Motors")),
    );
  }

}