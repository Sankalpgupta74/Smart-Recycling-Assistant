import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _logoScale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut)));
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AuthWrapper()));
      }
    });


  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E14),
                Color(0xFF0D2818),
                Color(0xFF0A0E14)
              ]),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F1722),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 2),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/app_logo.png', fit: BoxFit.cover, filterQuality: FilterQuality.high),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text('Recycle Easy',
                        style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('AI-Powered Waste Intelligence',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

