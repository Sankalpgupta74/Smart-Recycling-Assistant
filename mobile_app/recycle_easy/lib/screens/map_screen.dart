import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/report_model.dart';
import '../models/bin_model.dart';
import '../models/user_model.dart';
import '../providers/language_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class BinLocation {
  final String id;
  final String userId;
  final String title;
  final LatLng position;
  final String type;
  final bool isOfficial;
  const BinLocation({
    required this.id,
    required this.userId,
    required this.title,
    required this.position,
    required this.type,
    this.isOfficial = false,
  });
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final DatabaseService _dbService = DatabaseService();
  LatLng _currentLocation = const LatLng(27.6057, 77.5933); // Default GLA University
  bool _isLoading = true;
  bool _isSelectingBinLocation = false;

  final List<BinLocation> _glaBins = const [
    BinLocation(id: 'gla1', userId: 'official', title: "Main Block Plastic Bin", position: LatLng(27.6057, 77.5933), type: "Plastic", isOfficial: true),
    BinLocation(id: 'gla2', userId: 'official', title: "Cafeteria Organic Bin", position: LatLng(27.6062, 77.5940), type: "Organic", isOfficial: true),
    BinLocation(id: 'gla3', userId: 'official', title: "Library Dry Waste", position: LatLng(27.6050, 77.5925), type: "Paper", isOfficial: true),
    BinLocation(id: 'gla4', userId: 'official', title: "CS Block E-Waste", position: LatLng(27.6065, 77.5920), type: "E-Waste", isOfficial: true),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        if (_isLoading) {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
            _isLoading = false;
          });
        } else {
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_currentLocation, 15.0);
        }
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReportDialog(LatLng point) {
    if (_isSelectingBinLocation) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportForm(location: point),
    );
  }

  void _showAddBinDialog(LatLng point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddBinForm(location: point),
    );
  }

  void _showActionMenu() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.getText('contribute_how') ?? "How would you like to contribute?", style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), shape: BoxShape.circle),
                child: const ImageIcon(AssetImage('assets/icons/report_perfect.png'), color: Colors.redAccent, size: 24),
              ),
              title: Text(lang.getText('report_waste_title') ?? "Report Waste Pile", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(lang.getText('report_waste_sub') ?? "Report trash that needs picking up.", style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.getText('report_waste_msg') ?? "Tap anywhere on the map to report waste.")));
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.2), shape: BoxShape.circle),
                child: const ImageIcon(AssetImage('assets/icons/leaf_perfect.png'), color: Color(0xFF00E676), size: 24),
              ),
              title: Text(lang.getText('add_bin') ?? 'Add Smart Bin', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(lang.getText('add_bin_subtitle') ?? "Map a permanent bin for the community.", style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                _showBinLocationMethodDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBinLocationMethodDialog() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.getText('location_method') ?? "Location Method", style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.lightBlueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.my_location_rounded, color: Colors.lightBlueAccent),
              ),
              title: Text(lang.getText('use_current_location') ?? "Use Current Location", style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _determinePosition().then((_) {
                  _showAddBinDialog(_currentLocation);
                });
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.map_outlined, color: Color(0xFF00E676)),
              ),
              title: Text(lang.getText('select_on_map') ?? "Select on Map", style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isSelectingBinLocation = true);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('map_title') ?? "Waste Intelligence Map",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1722),
        elevation: 0,
        actions: [
          IconButton(
            icon: const ImageIcon(AssetImage('assets/icons/map_perfect.png'), size: 24, color: Color(0xFF00E676)),
            onPressed: _determinePosition,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BinModel>>(
              stream: _dbService.bins,
              builder: (context, binsSnapshot) {
                return StreamBuilder<List<WasteReport>>(
                  stream: _dbService.reports,
                  builder: (context, snapshot) {
                    List<Marker> markers = [];
                    
                    return Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) => _showReportDialog(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.recycle_easy',
                    ),
                    StreamBuilder<MapEvent>(
                      stream: _mapController.mapEventStream,
                      builder: (context, mapEventSnapshot) {
                        final currentZoom = _mapController.camera.zoom;
                        double zoomDiff = currentZoom - 15.0;
                        double markerSize = (60.0 * math.pow(1.15, zoomDiff)).clamp(20.0, 150.0);
                        
                        List<Marker> markers = [];
                        
                        // Official GLA Bins
                        for (var bin in _glaBins) {
                          markers.add(
                            Marker(
                              point: bin.position,
                              width: markerSize,
                              height: markerSize,
                              child: GestureDetector(
                                onTap: () => _showOfficialBinDetails(bin),
                                child: _buildOfficialBinLogo(bin.type, markerSize),
                              ),
                            ),
                          );
                        }

                        // Database Bins
                        if (binsSnapshot.hasData) {
                          for (var b in binsSnapshot.data!) {
                            BinLocation bin = BinLocation(
                              id: b.id,
                              userId: b.userId,
                              title: "${b.type} Bin",
                              position: LatLng(b.latitude, b.longitude),
                              type: b.type,
                              isOfficial: false,
                            );
                            markers.add(
                              Marker(
                                point: bin.position,
                                width: markerSize,
                                height: markerSize,
                                child: GestureDetector(
                                  onTap: () => _showOfficialBinDetails(bin),
                                  child: _buildOfficialBinLogo(bin.type, markerSize),
                                ),
                              ),
                            );
                          }
                        }

                        // User Location Marker
                        markers.add(
                          Marker(
                            point: _currentLocation,
                            width: markerSize * 0.85,
                            height: markerSize * 0.85,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blue, width: math.max(1.0, markerSize * 0.04)),
                              ),
                              child: Center(
                                child: ImageIcon(const AssetImage('assets/icons/map_perfect.png'), size: markerSize * 0.45, color: Colors.blue),
                              ),
                            ),
                          ),
                        );

                        if (snapshot.hasData) {
                          for (var report in snapshot.data!) {
                            markers.add(
                              Marker(
                                point: LatLng(report.latitude, report.longitude),
                                width: markerSize * 0.85,
                                height: markerSize * 0.85,
                                child: GestureDetector(
                                  onTap: () => _showReportDetails(report),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                    child: Icon(
                                      _getIconForWaste(report.wasteType),
                                      color: Colors.redAccent,
                                      size: markerSize * 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        return MarkerLayer(markers: markers);
                      },
                    ),
                  ],
                ),
                if (_isSelectingBinLocation)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 48.0),
                      child: Icon(Icons.location_on, size: 48, color: Color(0xFF00E676)),
                    ),
                  ),
                if (_isSelectingBinLocation)
                  Positioned(
                    top: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                      child: const Text("Move map to position pin over exactly where the bin is located.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            );
          },
        );
      },
    ),
      floatingActionButton: _isSelectingBinLocation
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _isSelectingBinLocation = false);
                _showAddBinDialog(_mapController.camera.center);
              },
              backgroundColor: const Color(0xFF00E676),
              label: const Text("Confirm Location", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.check_circle, color: Colors.black),
            )
          : FloatingActionButton.extended(
              onPressed: _showActionMenu,
              label: Text(lang.getText('contribute'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add, color: Colors.white),
              backgroundColor: const Color(0xFF0F1722),
            ),
    );
  }

  Widget _buildOfficialBinLogo(String type, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(color: Colors.white, width: math.max(2.0, size * 0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset('assets/app_logo.png', fit: BoxFit.cover, width: size, height: size),
            ),
          ),
          Icon(
            _getIconForWaste(type),
            color: const Color(0xFF00E676),
            size: size * 0.55,
          ),
        ],
      ),
    );
  }

  void _showOfficialBinDetails(BinLocation bin) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconForWaste(bin.type), color: const Color(0xFF00E676), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("OFFICIAL SMART BIN",
                          style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF00E676), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(bin.title,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white54, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text("Accepts: ${bin.type}\nPlease ensure items are empty and clean before disposal.", 
                        style: GoogleFonts.outfit(color: Colors.white70, height: 1.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.navigation_rounded, size: 20),
                label: Text(lang.getText('navigate') ?? "NAVIGATE (PROTOTYPE)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            
            // Delete Option for Owners
            if (!bin.isOfficial && bin.userId == FirebaseAuth.instance.currentUser?.uid) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF131C29),
                        title: const Text("Remove Bin?", style: TextStyle(color: Colors.white)),
                        content: Text(lang.getText('remove_bin_confirm') ?? "Are you sure you want to remove this bin from the community map?", style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(child: Text(lang.getText('cancel') ?? "CANCEL"), onPressed: () => Navigator.pop(ctx, false)),
                          TextButton(
                            child: Text(lang.getText('remove') ?? "REMOVE", style: const TextStyle(color: Colors.redAccent)),
                            onPressed: () => Navigator.pop(ctx, true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _dbService.deleteBin(bin.id);
                      await _dbService.updateUserMetrics(bin.userId, points: -100);
                      navigator.pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  label: Text(lang.getText('remove_bin') ?? "REMOVE FROM MAP", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(WasteReport report) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1722),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconForWaste(report.wasteType), color: const Color(0xFF00E676)),
                const SizedBox(width: 12),
                Text(report.wasteType.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            if (report.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(report.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text("${lang.getText('notes') ?? 'Notes'}: ${report.notes}", style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 8),
            Text("Reported by ${report.userName}", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
            
            // Delete Option for Owners
            if (report.userId == FirebaseAuth.instance.currentUser?.uid) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF131C29),
                        title: const Text("Delete Report?", style: TextStyle(color: Colors.white)),
                        content: Text(lang.getText('delete_report_confirm') ?? "This action will permanently remove your report from the map.", style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(child: Text(lang.getText('cancel') ?? "CANCEL"), onPressed: () => Navigator.pop(ctx, false)),
                          TextButton(
                            child: Text(lang.getText('delete') ?? "DELETE", style: const TextStyle(color: Colors.redAccent)),
                            onPressed: () => Navigator.pop(ctx, true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _dbService.deleteReport(report.id);
                      await _dbService.updateUserMetrics(report.userId, points: -50, reports: -1, waste: -1.0);
                      navigator.pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  label: Text(lang.getText('delete_report') ?? "DELETE REPORT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getIconForWaste(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Icons.local_drink_rounded;
      case 'organic': return Icons.spa_rounded;
      case 'e-waste': return Icons.electrical_services_rounded;
      default: return Icons.delete_rounded;
    }
  }
}

class _ReportForm extends StatefulWidget {
  final LatLng location;
  const _ReportForm({required this.location});

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final TextEditingController _notesController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  File? _image;
  String _selectedType = 'Plastic';
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add a photo.")));
      return;
    }
    
    setState(() => _isSubmitting = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      final imageUrl = await _dbService.uploadImage(_image!);
      
      if (imageUrl != null) {
        final report = WasteReport(
          id: '',
          userId: user?.uid ?? 'anon',
          userName: user?.displayName ?? 'Anonymous',
          latitude: widget.location.latitude,
          longitude: widget.location.longitude,
          imageUrl: imageUrl,
          wasteType: _selectedType,
          notes: _notesController.text,
          timestamp: DateTime.now(),
          status: 'pending',
        );
        await _dbService.createReport(report);
        await _dbService.updateUserMetrics(user!.uid, points: 50, reports: 1, waste: 1.0);
        messenger.showSnackBar(const SnackBar(content: Text("Report submitted! +50 pts")));
        navigator.pop();
      } else {
        if (mounted) {
          messenger.showSnackBar(const SnackBar(content: Text("Failed to upload image. Please try again.")));
          setState(() => _isSubmitting = false);
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang.getText('report_waste_title') ?? "Report Waste Site", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: _image != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_image!, fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [const ImageIcon(AssetImage('assets/icons/Scan Icon.png'), color: Colors.white38, size: 40), Text(lang.getText('take_photo') ?? "Take Photo", style: const TextStyle(color: Colors.white38))],
                    ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: const Color(0xFF0F1722),
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                labelText: lang.getText('waste_type') ?? "Waste Type",
                labelStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Plastic', 'Organic', 'E-Waste', 'Medical', 'Other']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: lang.getText('notes') ?? "Notes",
                labelStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text(lang.getText('submit_report') ?? "SUBMIT REPORT"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AddBinForm extends StatefulWidget {
  final LatLng location;
  const _AddBinForm({required this.location});

  @override
  State<_AddBinForm> createState() => _AddBinFormState();
}

class _AddBinFormState extends State<_AddBinForm> {
  final DatabaseService _dbService = DatabaseService();
  String _selectedType = 'Plastic';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      final bin = BinModel(
        id: '',
        userId: user?.uid ?? 'anon',
        userName: user?.displayName ?? 'Anonymous',
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
        type: _selectedType,
        timestamp: DateTime.now(),
      );
      
      await _dbService.createBin(bin);
      await _dbService.updateUserMetrics(user!.uid, points: 100);
      messenger.showSnackBar(const SnackBar(content: Text("Bin added! +100 pts")));
      navigator.pop();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text("Failed to add bin: ${e.toString()}")));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1722),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang.getText('add_bin') ?? "Add Smart Bin", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: const Color(0xFF0F1722),
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                labelText: lang.getText('waste_type') ?? "Bin Primary Category",
                labelStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Plastic', 'Organic', 'E-Waste', 'Medical', 'Paper', 'General']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text(lang.getText('confirm_location') ?? "ADD TO MAP", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
