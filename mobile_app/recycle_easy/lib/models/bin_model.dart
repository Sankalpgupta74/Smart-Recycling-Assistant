import 'package:cloud_firestore/cloud_firestore.dart';

class BinModel {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String type;
  final DateTime timestamp;

  BinModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.timestamp,
  });

  factory BinModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BinModel(
      id: doc.id,
      userId: data['userId'] ?? 'anon',
      userName: data['userName'] ?? 'Anonymous',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      type: data['type'] ?? 'General',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
