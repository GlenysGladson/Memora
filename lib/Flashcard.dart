import 'dart:async';
import 'package:flutter/material.dart';

// Flashcard model with a description
class Flashcard {
  final String question;
  final String answer;
  final String description; // Added description field

  Flashcard({
    required this.question,
    required this.answer,
    required this.description,
  });
}

class FlashcardPage extends StatefulWidget {
  final List<Flashcard> flashcards;

  const FlashcardPage({super.key, required this.flashcards});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  bool isTimerRunning = false;
  int remainingSeconds = 0;
  Timer? timer;

  // Start timer logic
  void startTimer(int minutes) {
    setState(() {
      remainingSeconds = minutes * 60;
      isTimerRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          timer.cancel();
          isTimerRunning = false;
        }
      });
    });
  }

  // Format time function
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSecs = seconds % 60;
    return '$minutes:${remainingSecs.toString().padLeft(2, '0')}';
  }

  // Timer dialog
  void showTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedMinutes = 25;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Set Pomodoro Timer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: DropdownButton<int>(
            value: selectedMinutes,
            items: [25, 30, 45, 60].map((int value) {
              return DropdownMenuItem<int>(
                  value: value, child: Text('$value minutes'));
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                selectedMinutes = newValue;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startTimer(selectedMinutes);
              },
              child: const Text(
                'Start',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickAndAnalyzeFile() async {
    // Add file picker functionality here
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flashcards",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: pickAndAnalyzeFile,
            tooltip: 'Upload File',
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isTimerRunning ? Colors.black12 : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              onPressed: showTimerDialog,
              icon: const Icon(Icons.timer, size: 20),
              label: Text(
                isTimerRunning ? formatTime(remainingSeconds) : 'Timer',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: widget.flashcards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No flashcards yet!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: pickAndAnalyzeFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload a file to analyze"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.flashcards.length,
              itemBuilder: (context, index) {
                return FlashcardItem(flashcard: widget.flashcards[index]);
              },
            ),
    );
  }
}

// Flashcard Item widget to handle tap and display the flashcard content
class FlashcardItem extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardItem({super.key, required this.flashcard});

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showAnswer =
              !showAnswer; // Toggle between showing question and answer
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                showAnswer
                    ? widget.flashcard.answer
                    : widget.flashcard.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              if (showAnswer)
                Text(
                  widget.flashcard.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlashcardAnswerPage extends StatelessWidget {
  final Flashcard flashcard;

  const FlashcardAnswerPage({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade50,
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    flashcard.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    flashcard.answer,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    flashcard.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
