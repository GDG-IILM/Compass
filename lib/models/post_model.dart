// models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final int commentCount;

  PostModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
  });

  // Factory constructor to create PostModel from Firestore data
  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      likes: map['likes'] != null
          ? List<String>.from(map['likes'])
          : [],
      commentCount: map['commentCount'] ?? 0,
    );
  }

  // Convert PostModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'commentCount': commentCount,
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

  // Check if user has liked this post
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  // Get number of likes
  int get likeCount => likes.length;

  // Create a copy of PostModel with updated fields
  PostModel copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? imageUrl,
    DateTime? createdAt,
    List<String>? likes,
    int? commentCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostModel(id: $id, author: $authorName, likes: ${likes.length})';
  }
}