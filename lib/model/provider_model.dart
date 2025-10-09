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
  final Map<String, dynamic> weeklyAvailability; // NEW FIELD
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> appPreferences;


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
    this.weeklyAvailability = const {}, // NEW FIELD
    this.notificationSettings = const {'push': true, 'email': false},
    this.appPreferences = const {'darkMode': false},
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
      weeklyAvailability: data['weeklyAvailability'] as Map<String, dynamic>? ?? {}, // NEW FIELD
      notificationSettings: data['notificationSettings'] as Map<String, dynamic>? ?? {'push': true, 'email': false},
      appPreferences: data['appPreferences'] as Map<String, dynamic>? ?? {'darkMode': false},
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
      'weeklyAvailability': weeklyAvailability, // NEW FIELD
      'notificationSettings': notificationSettings,
      'appPreferences': appPreferences,
    };
  }
}
