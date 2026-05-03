import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String preferredLanguage;
  final double totalWasteDiverted;
  final int totalPoints;
  final int totalScans;
  final int totalReports;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.preferredLanguage,
    this.totalWasteDiverted = 0.0,
    this.totalPoints = 0,
    this.totalScans = 0,
    this.totalReports = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? 'User',
      email: data['email'] ?? '',
      preferredLanguage: data['preferred_language'] ?? 'en',
      totalWasteDiverted: (data['total_waste_diverted'] ?? 0.0).toDouble(),
      totalPoints: data['total_points'] ?? 0,
      totalScans: data['total_scans'] ?? 0,
      totalReports: data['total_reports'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'preferred_language': preferredLanguage,
      'total_waste_diverted': totalWasteDiverted,
      'total_points': totalPoints,
      'total_scans': totalScans,
      'total_reports': totalReports,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
