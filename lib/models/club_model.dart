// models/club_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String contactEmail;
  final String imageUrl;
  final List<String> members;
  final List<String> admins;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, String> socialLinks;
  final String president;
  final String vicePresident;
  final String faculty;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.contactEmail,
    required this.imageUrl,
    required this.members,
    required this.admins,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.socialLinks = const {},
    this.president = '',
    this.vicePresident = '',
    this.faculty = '',
  });

  // Factory constructor to create ClubModel from Firestore document
  factory ClubModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ClubModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      admins: List<String>.from(map['admins'] ?? []),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      isActive: map['isActive'] ?? true,
      socialLinks: Map<String, String>.from(map['socialLinks'] ?? {}),
      president: map['president'] ?? '',
      vicePresident: map['vicePresident'] ?? '',
      faculty: map['faculty'] ?? '',
    );
  }

  // Convert ClubModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'contactEmail': contactEmail,
      'imageUrl': imageUrl,
      'members': members,
      'admins': admins,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'socialLinks': socialLinks,
      'president': president,
      'vicePresident': vicePresident,
      'faculty': faculty,
    };
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

  // Create a copy of the club with updated fields
  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? contactEmail,
    String? imageUrl,
    List<String>? members,
    List<String>? admins,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, String>? socialLinks,
    String? president,
    String? vicePresident,
    String? faculty,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      contactEmail: contactEmail ?? this.contactEmail,
      imageUrl: imageUrl ?? this.imageUrl,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      socialLinks: socialLinks ?? this.socialLinks,
      president: president ?? this.president,
      vicePresident: vicePresident ?? this.vicePresident,
      faculty: faculty ?? this.faculty,
    );
  }

  // Get member count
  int get memberCount => members.length;

  // Check if user is a member
  bool isMember(String userId) {
    return members.contains(userId);
  }

  // Check if user is an admin
  bool isAdmin(String userId) {
    return admins.contains(userId);
  }

  // Get social media links as a formatted list
  List<Map<String, String>> get formattedSocialLinks {
    return socialLinks.entries
        .map((entry) => {
      'platform': entry.key,
      'url': entry.value,
    })
        .toList();
  }

  // Check if club has social links
  bool get hasSocialLinks => socialLinks.isNotEmpty;

  // Get club leadership info
  Map<String, String> get leadership {
    return {
      'President': president,
      'Vice President': vicePresident,
      'Faculty Advisor': faculty,
    }..removeWhere((key, value) => value.isEmpty);
  }

  // Get formatted category for display
  String get formattedCategory {
    return category.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  String toString() {
    return 'ClubModel(id: $id, name: $name, category: $category, members: ${members.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClubModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for club categories
enum ClubCategory {
  technical,
  cultural,
  sports,
  academic,
  social,
  volunteer,
  arts,
  music,
  dance,
  drama,
  literature,
  photography,
  entrepreneurship,
  gaming,
  other,
}

// Extension to get display names for categories
extension ClubCategoryExtension on ClubCategory {
  String get displayName {
    switch (this) {
      case ClubCategory.technical:
        return 'Technical';
      case ClubCategory.cultural:
        return 'Cultural';
      case ClubCategory.sports:
        return 'Sports';
      case ClubCategory.academic:
        return 'Academic';
      case ClubCategory.social:
        return 'Social';
      case ClubCategory.volunteer:
        return 'Volunteer';
      case ClubCategory.arts:
        return 'Arts';
      case ClubCategory.music:
        return 'Music';
      case ClubCategory.dance:
        return 'Dance';
      case ClubCategory.drama:
        return 'Drama';
      case ClubCategory.literature:
        return 'Literature';
      case ClubCategory.photography:
        return 'Photography';
      case ClubCategory.entrepreneurship:
        return 'Entrepreneurship';
      case ClubCategory.gaming:
        return 'Gaming';
      case ClubCategory.other:
        return 'Other';
    }
  }

  static ClubCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return ClubCategory.technical;
      case 'cultural':
        return ClubCategory.cultural;
      case 'sports':
        return ClubCategory.sports;
      case 'academic':
        return ClubCategory.academic;
      case 'social':
        return ClubCategory.social;
      case 'volunteer':
        return ClubCategory.volunteer;
      case 'arts':
        return ClubCategory.arts;
      case 'music':
        return ClubCategory.music;
      case 'dance':
        return ClubCategory.dance;
      case 'drama':
        return ClubCategory.drama;
      case 'literature':
        return ClubCategory.literature;
      case 'photography':
        return ClubCategory.photography;
      case 'entrepreneurship':
        return ClubCategory.entrepreneurship;
      case 'gaming':
        return ClubCategory.gaming;
      default:
        return ClubCategory.other;
    }
  }
}