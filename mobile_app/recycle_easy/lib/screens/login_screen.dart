import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    } else {
      // Success - navigator will handle because of main.dart auth state listener
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E14), Color(0xFF0D2818), Color(0xFF0A0E14)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00B0FF)]),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.3),
                          blurRadius: 30),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset('assets/app_logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Welcome Back',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                Text('Sign in to continue your recycling journey',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white54,
                    )),
                const SizedBox(height: 48),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!,
                      style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13)),
                ],

                const SizedBox(height: 32),

                // Login Button
                _buildButton(
                  text: 'SIGN IN',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: GoogleFonts.outfit(color: Colors.white54)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                      },
                      child: Text("Sign Up",
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF00E676),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF00E676)],
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF00E676).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    text,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
