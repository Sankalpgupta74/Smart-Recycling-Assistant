import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/report_model.dart';
import '../models/bin_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream of user profile data
  Stream<UserModel?> userData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Ensure user profile exists in Firestore
  Future<void> ensureUserProfile(auth.User user, {String? name}) async {
    // Reload to ensure we get the latest displayName from Firebase Auth
    try { await user.reload(); } catch (_) {}
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    // Resolve best available name
    final resolvedName = (name?.isNotEmpty == true)
        ? name!
        : (currentUser?.displayName?.isNotEmpty == true ? currentUser!.displayName! : null)
            ?? (user.displayName?.isNotEmpty == true ? user.displayName! : null)
            ?? user.email?.split('@').first
            ?? 'Recycler';

    final userDoc = _firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'name': resolvedName,
        'email': user.email ?? '',
        'preferred_language': 'en',
        'total_waste_diverted': 0.0,
        'total_points': 0,
        'total_scans': 0,
        'total_reports': 0,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else {
      // Self-heal: update name if it's still the placeholder default
      final savedName = doc.data()?['name'] as String? ?? '';
      if (savedName.isEmpty || savedName == 'User' || savedName == 'Recycler') {
        await userDoc.update({'name': resolvedName});
      }
    }
  }

  // Update user metrics atomically
  Future<void> updateUserMetrics(String userId, {
    int points = 0,
    int reports = 0,
    int scans = 0,
    double waste = 0.0,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'total_points': FieldValue.increment(points),
      'total_reports': FieldValue.increment(reports),
      'total_scans': FieldValue.increment(scans),
      'total_waste_diverted': FieldValue.increment(waste),
    });
  }

  // Stream of all reports
  Stream<List<WasteReport>> get reports {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WasteReport.fromFirestore(doc)).toList();
    });
  }

  // Stream of all community bins
  Stream<List<BinModel>> get bins {
    return _firestore
        .collection('bins')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BinModel.fromFirestore(doc)).toList();
    });
  }
  
  // Upload image to Storage
  Future<String?> uploadImage(File image) async {
    try {
      String fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  // Create a new report in Firestore
  Future<void> createReport(WasteReport report) async {
    await _firestore.collection('reports').add(report.toFirestore());
  }

  // Create a new bin in Firestore
  Future<void> createBin(BinModel bin) async {
    await _firestore.collection('bins').add(bin.toFirestore());
  }

  // Delete a report
  Future<void> deleteReport(String id) async {
    await _firestore.collection('reports').doc(id).delete();
  }

  // Delete a bin
  Future<void> deleteBin(String id) async {
    await _firestore.collection('bins').doc(id).delete();
  }

  // Stream of user-specific reports
  Stream<List<WasteReport>> userReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WasteReport.fromFirestore(doc)).toList();
    });
  }

  // Cloud Sync Language
  Future<void> updateUserLanguage(String userId, String languageCode) async {
    await _firestore.collection('users').doc(userId).set({
      'preferred_language': languageCode,
    }, SetOptions(merge: true));
  }

  Future<String?> getUserLanguage(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['preferred_language'] as String?;
    }
    return null;
  }
}

