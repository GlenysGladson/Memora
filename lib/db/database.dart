import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Topics Methods
  Future<Stream<QuerySnapshot>> getTopics() async {
    return _firestore
        .collection('topics')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addTopic(String topicName) async {
    await _firestore.collection('topics').add({
      'name': topicName,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> updateTopic(String topicId, String newName) async {
    await _firestore.collection('topics').doc(topicId).update({
      'name': newName,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> deleteTopic(String topicId) async {
    // Delete the topic and all its flashcards
    await _firestore.collection('topics').doc(topicId).delete();
  }

  // Flashcards Methods
  Future<Stream<QuerySnapshot>> getFlashcards(String topicId) async {
    return _firestore
        .collection('topics')
        .doc(topicId)
        .collection('flashcards')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addFlashcard(
    Map<String, dynamic> flashcardData,
    String topicId,
    String cardId,
  ) async {
    await _firestore
        .collection('topics')
        .doc(topicId)
        .collection('flashcards')
        .doc(cardId)
        .set(flashcardData);
  }

  Future<void> updateFlashcard(
    String topicId,
    String cardId,
    Map<String, dynamic> newData,
  ) async {
    await _firestore
        .collection('topics')
        .doc(topicId)
        .collection('flashcards')
        .doc(cardId)
        .update(newData);
  }

  Future<void> deleteFlashcard(String topicId, String cardId) async {
    await _firestore
        .collection('topics')
        .doc(topicId)
        .collection('flashcards')
        .doc(cardId)
        .delete();
  }
}