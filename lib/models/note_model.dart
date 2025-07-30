class NoteModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? subject;
  final String? department;
  final String? semester;
  final String? year;
  final List<String> tags;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final bool isPinned;
  final NoteType type;
  final int likes;
  final int downloads;
  final int views;
  final List<String> likedBy;
  final NoteStatus status;
  final String? moderatorNote;
  final double? rating;
  final int ratingCount;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.subject,
    this.department,
    this.semester,
    this.year,
    this.tags = const [],
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = true,
    this.isPinned = false,
    this.type = NoteType.general,
    this.likes = 0,
    this.downloads = 0,
    this.views = 0,
    this.likedBy = const [],
    this.status = NoteStatus.approved,
    this.moderatorNote,
    this.rating,
    this.ratingCount = 0,
  });

  // Factory constructor to create NoteModel from JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      subject: json['subject'],
      department: json['department'],
      semester: json['semester'],
      year: json['year'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isPublic: json['isPublic'] ?? true,
      isPinned: json['isPinned'] ?? false,
      type: NoteType.values.firstWhere(
            (type) => type.name == json['type'],
        orElse: () => NoteType.general,
      ),
      likes: json['likes'] ?? 0,
      downloads: json['downloads'] ?? 0,
      views: json['views'] ?? 0,
      likedBy: json['likedBy'] != null
          ? List<String>.from(json['likedBy'])
          : [],
      status: NoteStatus.values.firstWhere(
            (status) => status.name == json['status'],
        orElse: () => NoteStatus.approved,
      ),
      moderatorNote: json['moderatorNote'],
      rating: json['rating']?.toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  // Convert NoteModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'subject': subject,
      'department': department,
      'semester': semester,
      'year': year,
      'tags': tags,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
      'isPinned': isPinned,
      'type': type.name,
      'likes': likes,
      'downloads': downloads,
      'views': views,
      'likedBy': likedBy,
      'status': status.name,
      'moderatorNote': moderatorNote,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  // Create a copy of NoteModel with updated fields
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? subject,
    String? department,
    String? semester,
    String? year,
    List<String>? tags,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    bool? isPinned,
    NoteType? type,
    int? likes,
    int? downloads,
    int? views,
    List<String>? likedBy,
    NoteStatus? status,
    String? moderatorNote,
    double? rating,
    int? ratingCount,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      subject: subject ?? this.subject,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      isPinned: isPinned ?? this.isPinned,
      type: type ?? this.type,
      likes: likes ?? this.likes,
      downloads: downloads ?? this.downloads,
      views: views ?? this.views,
      likedBy: likedBy ?? this.likedBy,
      status: status ?? this.status,
      moderatorNote: moderatorNote ?? this.moderatorNote,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  // Helper methods
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

  double get averageRating => rating ?? 0.0;

  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  bool get hasRating => rating != null && ratingCount > 0;

  String get typeDisplayName => type.displayName;

  String get statusDisplayName => status.displayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, author: $authorName, type: $type)';
  }
}

enum NoteType {
  general,
  lecture,
  assignment,
  exam,
  project,
  research,
  tutorial,
  summary,
  reference,
}

extension NoteTypeExtension on NoteType {
  String get displayName {
    switch (this) {
      case NoteType.general:
        return 'General';
      case NoteType.lecture:
        return 'Lecture Notes';
      case NoteType.assignment:
        return 'Assignment';
      case NoteType.exam:
        return 'Exam Material';
      case NoteType.project:
        return 'Project';
      case NoteType.research:
        return 'Research';
      case NoteType.tutorial:
        return 'Tutorial';
      case NoteType.summary:
        return 'Summary';
      case NoteType.reference:
        return 'Reference';
    }
  }

  String get icon {
    switch (this) {
      case NoteType.general:
        return '📝';
      case NoteType.lecture:
        return '🎓';
      case NoteType.assignment:
        return '📋';
      case NoteType.exam:
        return '📊';
      case NoteType.project:
        return '🚀';
      case NoteType.research:
        return '🔬';
      case NoteType.tutorial:
        return '🎯';
      case NoteType.summary:
        return '📄';
      case NoteType.reference:
        return '📚';
    }
  }
}

enum NoteStatus {
  pending,
  approved,
  rejected,
  flagged,
}

extension NoteStatusExtension on NoteStatus {
  String get displayName {
    switch (this) {
      case NoteStatus.pending:
        return 'Pending Review';
      case NoteStatus.approved:
        return 'Approved';
      case NoteStatus.rejected:
        return 'Rejected';
      case NoteStatus.flagged:
        return 'Flagged';
    }
  }

  bool get isVisible {
    return this == NoteStatus.approved;
  }

  bool get needsReview {
    return this == NoteStatus.pending || this == NoteStatus.flagged;
  }
}