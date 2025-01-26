class Topic {
  final String id;
  final String name;
  final DateTime? createdAt;

  Topic({
    required this.id,
    required this.name,
    this.createdAt,
  });

  // Convert Firestore document to Topic object
  factory Topic.fromMap(Map<String, dynamic> map, String id) {
    return Topic(
      id: id,
      name: map['name'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  // Convert Topic object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt,
    };
  }

  // Create a copy of Topic with some fields changed
  Topic copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}