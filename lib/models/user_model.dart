class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? location;
  final String? favoriteDiscs;
  final String subscriptionTier; // 'free', 'basic', 'premium'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.location,
    this.favoriteDiscs,
    this.subscriptionTier = 'free',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'location': location,
      'favoriteDiscs': favoriteDiscs,
      'subscriptionTier': subscriptionTier,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      location: map['location'],
      favoriteDiscs: map['favoriteDiscs'],
      subscriptionTier: map['subscriptionTier'] ?? 'free',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
