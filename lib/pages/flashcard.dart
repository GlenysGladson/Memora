class Flashcard {
  final String id;
  final String topicId;
  final String keyword;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Flashcard({
    required this.id,
    required this.topicId,
    required this.keyword,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Firestore document to Flashcard object
  factory Flashcard.fromMap(Map<String, dynamic> map, String id) {
    return Flashcard(
      id: id,
      topicId: map['topicId'] ?? '',
      keyword: map['keyword'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // Convert Flashcard object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'keyword': keyword,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of Flashcard with some fields changed
  Flashcard copyWith({
    String? id,
    String? topicId,
    String? keyword,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      keyword: keyword ?? this.keyword,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}