import 'package:cloud_firestore/cloud_firestore.dart';

class WasteReport {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String wasteType;
  final String notes;
  final DateTime timestamp;
  final String status;

  WasteReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.wasteType,
    required this.notes,
    required this.timestamp,
    required this.status,
  });

  factory WasteReport.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return WasteReport(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      latitude: (data['location'] as GeoPoint).latitude,
      longitude: (data['location'] as GeoPoint).longitude,
      imageUrl: data['imageUrl'] ?? '',
      wasteType: data['wasteType'] ?? '',
      notes: data['notes'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'location': GeoPoint(latitude, longitude),
      'imageUrl': imageUrl,
      'wasteType': wasteType,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }
}
