class ProviderModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePictureUrl;
  final double averageRating;
  final List<String> certifiedSkills;
  // --- NEW FIELDS ---
  final String? aadharUrl;
  final String? licenseUrl;

  ProviderModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePictureUrl,
    this.averageRating = 0.0,
    this.certifiedSkills = const [],
    // --- ADD TO CONSTRUCTOR ---
    this.aadharUrl,
    this.licenseUrl,
  });

  factory ProviderModel.fromMap(Map<String, dynamic> data) {
    return ProviderModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      certifiedSkills: List<String>.from(data['certifiedSkills'] ?? []),
      // --- ADD TO fromMap ---
      aadharUrl: data['aadharUrl'],
      licenseUrl: data['licenseUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePictureUrl': profilePictureUrl,
      'averageRating': averageRating,
      'certifiedSkills': certifiedSkills,
      // --- ADD TO toMap ---
      'aadharUrl': aadharUrl,
      'licenseUrl': licenseUrl,
    };
  }
}
