// models/note_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String fileUrl;
  final String branch;
  final int semester;
  final String uploaderId;
  final String uploaderName;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.fileUrl,
    required this.branch,
    required this.semester,
    required this.uploaderId,
    required this.uploaderName,
    required this.createdAt,
  });

  // Factory constructor to create NoteModel from Firestore data
  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? 1,
      uploaderId: map['uploaderId'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert NoteModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'fileUrl': fileUrl,
      'branch': branch,
      'semester': semester,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper method to get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Create a copy of NoteModel with updated fields
  NoteModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? description,
    String? fileUrl,
    String? branch,
    int? semester,
    String? uploaderId,
    String? uploaderName,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, subject: $subject, branch: $branch)';
  }
}