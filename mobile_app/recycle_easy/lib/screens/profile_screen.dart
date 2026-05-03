import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../providers/language_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi',
    'fr': 'French',
    'es': 'Spanish',
    'ja': 'Japanese',
    'it': 'Italian',
  };

  Future<void> _changeLanguage() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    String? newLang = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1722),
          title: Text("Select Language", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.entries.map((entry) {
              return ListTile(
                title: Text(entry.value, style: const TextStyle(color: Colors.white70)),
                trailing: langProvider.currentLanguage == entry.key ? const Icon(Icons.check, color: Color(0xFF00E676)) : null,
                onTap: () => Navigator.pop(context, entry.key),
              );
            }).toList(),
          ),
        );
      }
    );

    if (newLang != null && newLang != langProvider.currentLanguage) {
      await langProvider.setLanguage(newLang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();
    final DatabaseService dbService = DatabaseService();
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('profile_title') ?? 'Your Profile',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1722),
        elevation: 0,
        actions: [
          IconButton(
            icon: const ImageIcon(AssetImage('assets/icons/logout_perfect.png'), color: Colors.redAccent, size: 24),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1722), Color(0xFF0A0E14)],
          ),
        ),
        child: StreamBuilder<UserModel?>(
          stream: user != null ? dbService.userData(user.uid) : Stream.value(null),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data;
            
            return StreamBuilder<List<WasteReport>>(
              stream: dbService.userReports(user?.uid ?? ''),
              builder: (context, reportsSnapshot) {
                final reports = reportsSnapshot.data ?? [];
                final totalPoints = userData?.totalPoints ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Header
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00E676), width: 2),
                            image: DecorationImage(
                              image: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${userData?.email ?? user?.email}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(userData?.name ?? user?.displayName ?? 'Recycler Hero',
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(userData?.email ?? user?.email ?? 'hero@recycleeasy.com',
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54)),
                      const SizedBox(height: 32),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(lang.getText('points') ?? 'POINTS', totalPoints.toString(), const Color(0xFF00E676)),
                          _buildStatCard(lang.getText('rank') ?? 'RANK', '#--', const Color(0xFF00B0FF)),
                          _buildStatCard(lang.getText('level') ?? 'LEVEL', (totalPoints ~/ 500 + 1).toString(), const Color(0xFFFFCA28)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Activity Section
                      _buildSectionHeader(lang.getText('recent_activity') ?? 'Recent Activity', reports.length),
                      const SizedBox(height: 16),
                      
                      if (reports.isEmpty)
                        Opacity(
                          opacity: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                const ImageIcon(AssetImage('assets/icons/history_perfect.png'), size: 48, color: Colors.white24),
                                const SizedBox(height: 8),
                                Text(lang.getText('no_activity') ?? "No activity yet. Start recycling!", style: GoogleFonts.outfit(color: Colors.white38)),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reports.length > 5 ? 5 : reports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return _buildActivityTile(
                              icon: report.status == 'scanned' ? Icons.document_scanner_rounded : Icons.location_on_rounded,
                              title: report.status == 'scanned' ? '${report.wasteType} Scanned' : 'Reported ${report.wasteType}',
                              time: DateFormat('MMM d, h:mm a').format(report.timestamp),
                              points: report.status == 'scanned' ? '+10' : '+50',
                            );
                          },
                        ),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader(lang.getText('account_settings') ?? 'Account Settings', 0, showViewAll: false),
                      const SizedBox(height: 16),
                      _buildSettingsTile(
                        const ImageIcon(AssetImage('assets/icons/notification_perfect.png'), color: Colors.white54, size: 22),
                        lang.getText('notifications') ?? 'Notifications',
                      ),
                      _buildSettingsTile(
                        const ImageIcon(AssetImage('assets/icons/language_perfect.png'), color: Colors.white54, size: 22),
                        '${lang.getText('lang_selector') ?? 'Language'} (${_languages[lang.currentLanguage] ?? 'English'})',
                        onTap: _changeLanguage,
                      ),
                      _buildSettingsTile(
                        const ImageIcon(AssetImage('assets/icons/help_perfect.png'), color: Colors.white54, size: 22),
                        lang.getText('help_support') ?? 'Help & Support',
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const ImageIcon(AssetImage('assets/icons/logout_perfect.png'), color: Colors.redAccent, size: 22),
                        title: Text(lang.getText('sign_out') ?? "Sign Out", style: GoogleFonts.outfit(fontSize: 15, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        onTap: () => authService.signOut(),
                      ),
                      
                      const SizedBox(height: 48),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: GoogleFonts.outfit(fontSize: 10, color: color.withOpacity(0.7), letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, {bool showViewAll = true}) {
    return Row(
      children: [
        Text(title,
            style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const Spacer(),
        if (showViewAll && count > 0)
          Text('View All ($count)',
              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF00E676))),
      ],
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String time,
    required String points,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF00E676)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(time,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          Text(points,
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF00E676))),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(Widget leading, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: leading,
      title: Text(title,
          style: GoogleFonts.outfit(fontSize: 15, color: Colors.white70)),
      trailing: const ImageIcon(AssetImage('assets/icons/chevron_perfect.png'), color: Colors.white24, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
