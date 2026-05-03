import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/language_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLanguage = 'en';

  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi',
    'fr': 'French',
    'es': 'Spanish',
    'ja': 'Japanese',
    'it': 'Italian',
  };

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    } else {
      final langProvider = Provider.of<LanguageProvider>(context, listen: false);
      await langProvider.setLanguage(_selectedLanguage);
      
      // Ensure User Profile is initialized in Firestore immediately, passing name directly
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await langProvider.dbService.ensureUserProfile(user, name: _nameController.text.trim());
      }
      
      // Success - navigator will pop or main.dart will handle
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E14), Color(0xFF0A141A), Color(0xFF0A0E14)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text('Create Account',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                Text('Join the recycling revolution today',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white54,
                    )),
                const SizedBox(height: 40),

                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  dropdownColor: const Color(0xFF0F1722),
                  icon: const ImageIcon(AssetImage('assets/icons/language_perfect.png'), color: Colors.white54, size: 20),
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Preferred Language",
                    labelStyle: GoogleFonts.outfit(color: Colors.white54),
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
                  items: _languages.entries
                      .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLanguage = val ?? 'en'),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!,
                      style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13)),
                ],

                const SizedBox(height: 32),

                _buildButton(
                  text: 'SIGN UP',
                  onPressed: _isLoading ? null : _signup,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                        style: GoogleFonts.outfit(color: Colors.white54)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text("Sign In",
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF00E676),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
