import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../providers/language_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1722), Color(0xFF0A0E14)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(lang.getText('impact_title') ?? 'Your Eco-Impact',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const ImageIcon(AssetImage('assets/icons/notification_perfect.png'), size: 28, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero impact card
              _buildImpactCard(context),
              const SizedBox(height: 32),

              _buildSectionHeader(lang.getText('progress_overview') ?? 'Progress Overview'),
              const SizedBox(height: 16),
              _buildWeeklyChart(),
              const SizedBox(height: 32),

              _buildSectionHeader(lang.getText('recycling_tips') ?? 'Recycling Tips'),
              const SizedBox(height: 16),
              _buildTipCard(
                'Organic Waste: Composting',
                'By composting your food scraps, you reduce methane emissions from landfills and create nutrient-rich soil.',
                const ImageIcon(AssetImage('assets/icons/leaf_perfect.png'), color: Color(0xFF00E676), size: 24),
                const Color(0xFF00E676),
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                'E-Waste: Proper Disposal',
                'Old batteries and electronics contain toxic metals. Never throw them in the regular bin!',
                const ImageIcon(AssetImage('assets/icons/plug_perfect.png'), color: Color(0xFF00B0FF), size: 24),
                const Color(0xFF00B0FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final user = Provider.of<auth.User?>(context);
    final dbService = DatabaseService();

    return StreamBuilder<UserModel?>(
      stream: user != null ? dbService.userData(user.uid) : Stream.value(null),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00E676).withOpacity(0.05), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(lang.getText('planet_saved') ?? 'Planet Saved',
                      style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF00E676), fontWeight: FontWeight.w600)),
                  const ImageIcon(AssetImage('assets/icons/planet_perfect.png'), color: Color(0xFF00E676)),
                ],
              ),
              const SizedBox(height: 12),
              Text('${userData?.totalWasteDiverted.toStringAsFixed(1) ?? "0.0"} kg',
                  style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(lang.getText('total_waste') ?? 'Total Waste Diverted',
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat('${userData?.totalScans ?? 0}', 'Scans', const Color(0xFF00B0FF)),
                  const SizedBox(width: 20),
                  _buildMiniStat('${userData?.totalReports ?? 0}', 'Reports', const Color(0xFFFFCA28)),
                  const SizedBox(width: 20),
                  _buildMiniStat('${userData?.totalPoints ?? 0}', 'Points', const Color(0xFF00E676)),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white));
  }

  Widget _buildWeeklyChart() {
    final int currentWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBar(0.4, 'M', active: currentWeekday == 1),
          _buildBar(0.7, 'T', active: currentWeekday == 2),
          _buildBar(0.3, 'W', active: currentWeekday == 3),
          _buildBar(0.5, 'T', active: currentWeekday == 4),
          _buildBar(0.9, 'F', active: currentWeekday == 5),
          _buildBar(0.6, 'S', active: currentWeekday == 6),
          _buildBar(0.2, 'S', active: currentWeekday == 7),
        ],
      ),
    );
  }

  Widget _buildBar(double factor, String day, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 100 * factor,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00E676) : Colors.white10,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: GoogleFonts.outfit(fontSize: 12, color: active ? Colors.white : Colors.white24)),
      ],
    );
  }

  Widget _buildTipCard(String title, String subtitle, Widget iconWidget, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconWidget,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
