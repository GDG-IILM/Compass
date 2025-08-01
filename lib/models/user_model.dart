// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Changed from 'id' to 'uid' to match Firebase Auth
  final String email;
  final String name; // Combined name instead of firstName/lastName
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? studentId;
  final String branch; // Changed from 'department' to 'branch'
  final int semester; // Changed from 'year' to 'semester'
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
    required this.uid,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.phoneNumber,
    this.studentId,
    required this.branch,
    required this.semester,
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

  // Getter for compatibility
  String get id => uid;
  String get fullName => name;
  String get displayName => name;
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      email: map['email'] ?? '',
      name: map['fullName'] ?? map['name'] ?? '', // Support both field names
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      studentId: map['studentId'],
      branch: map['branch'] ?? map['department'] ?? 'Computer Science', // Support both
      semester: map['semester'] ?? _parseYear(map['year']) ?? 1, // Convert year to semester
      section: map['section'],
      rollNumber: map['rollNumber'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      isEmailVerified: map['isEmailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      role: _parseUserRole(map['role']),
      preferences: map['preferences'],
      interests: map['interests'] != null
          ? List<String>.from(map['interests'])
          : null,
      bio: map['bio'],
      dateOfBirth: map['dateOfBirth'] != null
          ? _parseDateTime(map['dateOfBirth'])
          : null,
      address: map['address'],
      emergencyContact: map['emergencyContact'],
    );
  }

  // Factory constructor from JSON (for backward compatibility)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json, json['uid'] ?? json['id'] ?? '');
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': name, // Store as fullName for consistency
      'name': name, // Also store as name for compatibility
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'studentId': studentId,
      'branch': branch,
      'semester': semester,
      'section': section,
      'rollNumber': rollNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'role': role.name,
      'preferences': preferences,
      'interests': interests,
      'bio': bio,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }

  // Convert UserModel to JSON (for backward compatibility)
  Map<String, dynamic> toJson() {
    final map = toMap();
    // Convert Timestamps back to ISO strings for JSON
    map['createdAt'] = createdAt.toIso8601String();
    map['updatedAt'] = updatedAt.toIso8601String();
    if (dateOfBirth != null) {
      map['dateOfBirth'] = dateOfBirth!.toIso8601String();
    }
    return map;
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();

    if (dateTime is Timestamp) {
      return dateTime.toDate();
    } else if (dateTime is DateTime) {
      return dateTime;
    } else if (dateTime is String) {
      return DateTime.tryParse(dateTime) ?? DateTime.now();
    } else {
      return DateTime.now();
    }
  }

  // Helper method to parse UserRole
  static UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.student;

    if (role is UserRole) return role;

    final roleString = role.toString().toLowerCase();
    switch (roleString) {
      case 'faculty':
        return UserRole.faculty;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  // Helper method to convert year string to semester number
  static int _parseYear(dynamic year) {
    if (year == null) return 1;

    if (year is int) return year * 2 - 1; // Convert year to first semester

    final yearString = year.toString().toLowerCase();
    switch (yearString) {
      case '1st':
      case 'first':
      case '1':
        return 1;
      case '2nd':
      case 'second':
      case '2':
        return 3;
      case '3rd':
      case 'third':
      case '3':
        return 5;
      case '4th':
      case 'fourth':
      case '4':
        return 7;
      default:
        return 1;
    }
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profileImageUrl,
    String? phoneNumber,
    String? studentId,
    String? branch,
    int? semester,
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
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentId: studentId ?? this.studentId,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
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

  // Get formatted semester display
  String get formattedSemester => 'Semester $semester';

  // Get year from semester
  int get year => ((semester - 1) ~/ 2) + 1;

  // Get formatted year display
  String get formattedYear => 'Year $year';

  // Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        branch.isNotEmpty &&
        semester > 0;
  }

  // Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 8;

    if (name.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (branch.isNotEmpty) completedFields++;
    if (semester > 0) completedFields++;
    if (phoneNumber?.isNotEmpty == true) completedFields++;
    if (studentId?.isNotEmpty == true) completedFields++;
    if (bio?.isNotEmpty == true) completedFields++;
    if (profileImageUrl?.isNotEmpty == true) completedFields++;

    return completedFields / totalFields;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, branch: $branch, semester: $semester)';
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