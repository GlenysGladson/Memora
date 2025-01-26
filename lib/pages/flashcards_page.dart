import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/database.dart';

class FlashcardsPage extends StatelessWidget {
  final String topicId;
  final String topicName;
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  FlashcardsPage({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topicName),
        centerTitle: true,
      ),
      body: FutureBuilder<Stream<QuerySnapshot>>(
        future: _databaseMethods.getFlashcards(topicId),
        builder: (context, AsyncSnapshot<Stream<QuerySnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: snapshot.data!,
            builder: (context, AsyncSnapshot<QuerySnapshot> cardsSnapshot) {
              if (cardsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (cardsSnapshot.hasError) {
                return Center(child: Text('Error: ${cardsSnapshot.error}'));
              }

              if (!cardsSnapshot.hasData || cardsSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No flashcards added yet'));
              }

              return ListView.builder(
                itemCount: cardsSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = cardsSnapshot.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(doc['keyword']),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['description']),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditDialog(
                                      context,
                                      doc.id,
                                      doc['keyword'],
                                      doc['description'],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _showDeleteDialog(
                                      context,
                                      doc.id,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _showRevisionDialog(context),
              label: const Text('Revision'),
              icon: const Icon(Icons.refresh),
              heroTag: 'revision',
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () => _showAddFlashcardDialog(context),
              child: const Icon(Icons.add),
              heroTag: 'add',
            ),
          ],
        ),
      ),
    );
  }

  void _showRevisionDialog(BuildContext context) async {
    final flashcardsStream = await _databaseMethods.getFlashcards(topicId);
    
    flashcardsStream.first.then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flashcards available for revision')),
        );
        return;
      }

      // Get a random flashcard
      final random = DateTime.now().millisecondsSinceEpoch;
      final randomIndex = random % snapshot.docs.length;
      final randomCard = snapshot.docs[randomIndex];

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Revision'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keyword:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(randomCard['keyword']),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Description'),
                      content: Text(randomCard['description']),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showRevisionDialog(context); // Show next random card
              },
              child: const Text('Next'),
            ),
          ],
        ),
      );
    });
  }

  void _showAddFlashcardDialog(BuildContext context) {
    final TextEditingController keywordController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keywordController,
              decoration: const InputDecoration(
                hintText: 'Enter keyword',
                labelText: 'Keyword',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (keywordController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                String cardId = DateTime.now().millisecondsSinceEpoch.toString();
                Map<String, dynamic> flashcardData = {
                  "keyword": keywordController.text.trim(),
                  "description": descriptionController.text.trim(),
                  "createdAt": DateTime.now(),
                };
                _databaseMethods.addFlashcard(flashcardData, topicId, cardId);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String cardId,
    String currentKeyword,
    String currentDescription,
  ) {
    final TextEditingController keywordController =
        TextEditingController(text: currentKeyword);
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keywordController,
              decoration: const InputDecoration(
                hintText: 'Enter keyword',
                labelText: 'Keyword',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (keywordController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                Map<String, dynamic> newData = {
                  "keyword": keywordController.text.trim(),
                  "description": descriptionController.text.trim(),
                  "updatedAt": DateTime.now(),
                };
                _databaseMethods.updateFlashcard(topicId, cardId, newData);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _databaseMethods.deleteFlashcard(topicId, cardId);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}