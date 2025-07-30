class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? studentId;
  final String? department;
  final String? year;
  final String? section;
  final String? rollNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  final UserRole role;
  final Map<String, dynamic>? preferences;
  final List<String>? interests;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? address;
  final String? emergencyContact;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.studentId,
    this.department,
    this.year,
    this.section,
    this.rollNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isActive = true,
    this.role = UserRole.student,
    this.preferences,
    this.interests,
    this.bio,
    this.dateOfBirth,
    this.address,
    this.emergencyContact,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => fullName;
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  // Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      phoneNumber: json['phoneNumber'],
      studentId: json['studentId'],
      department: json['department'],
      year: json['year'],
      section: json['section'],
      rollNumber: json['rollNumber'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      role: UserRole.values.firstWhere(
            (role) => role.name == json['role'],
        orElse: () => UserRole.student,
      ),
      preferences: json['preferences'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      bio: json['bio'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
      emergencyContact: json['emergencyContact'],
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'studentId': studentId,
      'department': department,
      'year': year,
      'section': section,
      'rollNumber': rollNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'role': role.name,
      'preferences': preferences,
      'interests': interests,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? phoneNumber,
    String? studentId,
    String? department,
    String? year,
    String? section,
    String? rollNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
    UserRole? role,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    String? bio,
    DateTime? dateOfBirth,
    String? address,
    String? emergencyContact,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }
}

enum UserRole {
  student,
  faculty,
  admin,
  moderator,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.moderator:
        return 'Moderator';
    }
  }

  bool get canModerate {
    return this == UserRole.admin || this == UserRole.moderator;
  }

  bool get isAdmin {
    return this == UserRole.admin;
  }

  bool get isFaculty {
    return this == UserRole.faculty;
  }

  bool get isStudent {
    return this == UserRole.student;
  }
}