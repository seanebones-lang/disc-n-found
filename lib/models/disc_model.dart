class DiscModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String description;
  final String status; // 'lost' or 'found'
  final String? location;
  final String? claimedBy;
  final DateTime timestamp;

  DiscModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.status,
    this.location,
    this.claimedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'location': location,
      'claimedBy': claimedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DiscModel.fromMap(Map<String, dynamic> map, String id) {
    return DiscModel(
      id: id,
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'found',
      location: map['location'],
      claimedBy: map['claimedBy'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  bool get isClaimed => claimedBy != null;
}
