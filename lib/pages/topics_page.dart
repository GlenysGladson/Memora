import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/database.dart';
import 'flashcards_page.dart';

class TopicsPage extends StatelessWidget {
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  TopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        centerTitle: true,
      ),
      body: FutureBuilder<Stream<QuerySnapshot>>(
        future: _databaseMethods.getTopics(),
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
            builder: (context, AsyncSnapshot<QuerySnapshot> topicsSnapshot) {
              if (topicsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (topicsSnapshot.hasError) {
                return Center(child: Text('Error: ${topicsSnapshot.error}'));
              }

              if (!topicsSnapshot.hasData || topicsSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No topics added yet'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: topicsSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = topicsSnapshot.data!.docs[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        doc['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: doc['createdAt'] != null
                          ? Text(
                              'Created: ${_formatDate(doc['createdAt'].toDate())}',
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditTopicDialog(
                              context,
                              doc.id,
                              doc['name'],
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashcardsPage(
                              topicId: doc.id,
                              topicName: doc['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTopicDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Topic',
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTopicDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Topic'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter topic name',
            labelText: 'Topic Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                try {
                  await _databaseMethods.addTopic(textController.text.trim());
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding topic: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTopicDialog(
    BuildContext context,
    String topicId,
    String currentName,
  ) {
    final textController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Topic'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter topic name',
            labelText: 'Topic Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                try {
                  await _databaseMethods.updateTopic(
                    topicId,
                    textController.text.trim(),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating topic: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String topicId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: const Text(
          'Are you sure you want to delete this topic? This will also delete all flashcards in this topic.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _databaseMethods.deleteTopic(topicId);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting topic: $e')),
                );
              }
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