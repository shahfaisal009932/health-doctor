class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final String experience;
  final String degree;
  final double fee;
  final String bio;
  final bool isAvailable;
  final List<String> availability;
  final String profileImageUrl;
  final double rating;
  final int totalRatings;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.specialization = 'General Physician',
    this.experience = '0 years',
    this.degree = '',
    this.fee = 0,
    this.bio = '',
    this.isAvailable = true,
    this.availability = const [],
    this.profileImageUrl = '',
    this.rating = 0,
    this.totalRatings = 0,
  });

  factory DoctorModel.fromMap(String id, Map<String, dynamic> map) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      specialization: map['specialization'] ?? 'General Physician',
      experience: map['experience'] ?? '0 years',
      degree: map['degree'] ?? '',
      fee: (map['fee'] is num) ? (map['fee'] as num).toDouble() : 0,
      bio: map['bio'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      availability: map['availability'] is List
          ? (map['availability'] as List).map((e) => e.toString()).toList()
          : const [],
      profileImageUrl: map['profileImageUrl'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0,
      totalRatings:
          (map['totalRatings'] is num) ? (map['totalRatings'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'specialization': specialization,
      'experience': experience,
      'degree': degree,
      'fee': fee,
      'bio': bio,
      'isAvailable': isAvailable,
      'availability': availability,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }
}
