import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'services/auth_service.dart';
import 'providers/language_provider.dart';
import 'screens/auth_wrapper.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  if (kDebugMode) print("[DEBUG] Initializing App Check...");
  
  // Initialize App Check with Debug Provider for local development
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,

    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );
  
  runApp(const RecycleEasyApp());
}

class RecycleEasyApp extends StatelessWidget {
  const RecycleEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<auth.User?>(
          create: (_) => AuthService().user,
          initialData: null,
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RecycleEasy AI',
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0A0E14),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}