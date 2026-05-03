import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'main_navigation.dart';
import 'login_screen.dart';
import '../providers/language_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<auth.User?>(context);

    if (user != null) {
      if (_lastUserId != user.uid) {
        _lastUserId = user.uid;
        // Trigger cloud sync and ensure profile exists when user logs in
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final langProvider = Provider.of<LanguageProvider>(context, listen: false);
          await langProvider.syncWithFirestore(user.uid);
          // Initial Profile Setup
          await langProvider.dbService.ensureUserProfile(user);
        });
      }
      return const MainNavigation();
    } else {
      _lastUserId = null;
      return const LoginScreen();
    }
  }
}
