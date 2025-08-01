// models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final DateTime date;
  final String location;
  final String imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int maxAttendees;
  final List<String> attendees;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.maxAttendees = 0,
    this.attendees = const [],
  });

  // Factory constructor to create EventModel from Firestore document
  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      organizer: map['organizer'] ?? '',
      date: _parseDateTime(map['date']),
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      isActive: map['isActive'] ?? true,
      maxAttendees: map['maxAttendees'] ?? 0,
      attendees: List<String>.from(map['attendees'] ?? []),
    );
  }

  // Convert EventModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'organizer': organizer,
      'date': Timestamp.fromDate(date),
      'location': location,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'maxAttendees': maxAttendees,
      'attendees': attendees,
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

  // Create a copy of the event with updated fields
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? organizer,
    DateTime? date,
    String? location,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? maxAttendees,
    List<String>? attendees,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      attendees: attendees ?? this.attendees,
    );
  }

  // Check if event is upcoming
  bool get isUpcoming => date.isAfter(DateTime.now());

  // Check if event is past
  bool get isPast => date.isBefore(DateTime.now());

  // Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Get formatted date string
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Get formatted time string
  String get formattedTime {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Check if user can attend (not full)
  bool get canAttend {
    if (maxAttendees == 0) return true; // No limit
    return attendees.length < maxAttendees;
  }

  // Get remaining spots
  int get remainingSpots {
    if (maxAttendees == 0) return -1; // No limit
    return maxAttendees - attendees.length;
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, date: $date, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}