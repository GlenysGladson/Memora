import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:memora/model.dart';

// Flashcard model, you'll need this class to represent flashcards
class Flashcard {
  final String question;
  final String answer;
  final Color backgroundColor;

  Flashcard({
    required this.question,
    required this.answer,
    required this.backgroundColor,
  });
}



class LearnWithAIPage extends StatelessWidget {
  const LearnWithAIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memora',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.lightBlue[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
    //        Image.asset(
       //       'assets/memora_logo.png',
       //       width: 120,
        //      height: 120,
        //    ),
            const SizedBox(height: 24),
            const Text(
              'Memora',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Flashcard> flashcards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GeminiChatBot(flashcards: flashcards),
          FlashcardPage(flashcards: flashcards),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.blue[300],
        backgroundColor: Colors.lightBlue[100],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            activeIcon: Icon(Icons.style),
            label: 'Cards',
          ),
        ],
      ),
    );
  }
}

class GeminiChatBot extends StatefulWidget {
  final List<Flashcard> flashcards;
  const GeminiChatBot({super.key, required this.flashcards});

  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  TextEditingController promptController = TextEditingController();
  static const apiKey = 'AIzaSyDbASkP9C8u74GGiiwJNypbjmXwnz4n6V0';
  final model = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
  final List<ModelMessage> prompt = [];

  Future<void> sendMessage() async {
    final message = promptController.text;
    if (message.trim().isEmpty) return;

    setState(() {
      promptController.clear();
      prompt.add(
        ModelMessage(
          isPrompt: true,
          message: message,
          time: DateTime.now(),
        ),
      );
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    final aiResponse = response.text ?? "";

    setState(() {
      prompt.add(
        ModelMessage(
          isPrompt: false,
          message: aiResponse,
          time: DateTime.now(),
        ),
      );

      // Adding the flashcard after getting AI response
      widget.flashcards.add(Flashcard(
        question: message,
        answer: aiResponse,
        backgroundColor: Colors.lightBlue[50]!,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memora Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: prompt.length,
              itemBuilder: (context, index) {
                final message = prompt[index];
                return UserPrompt(
                  isPrompt: message.isPrompt,
                  message: message.message,
                  date: DateFormat('hh:mm a').format(message.time),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Add file upload functionality here if needed
                  },
                  icon: const Icon(Icons.upload_file),
                  color: Colors.blue[900],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: promptController,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Ask anything...",
                      hintStyle: TextStyle(color: Colors.blue[300]),
                      filled: true,
                      fillColor: Colors.lightBlue[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.blue[900],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget UserPrompt({
    required bool isPrompt,
    required String message,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: isPrompt ? 40 : 0,
        right: isPrompt ? 0 : 40,
        bottom: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrompt ? Colors.lightBlue[50] : Colors.lightBlue[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isPrompt ? Colors.black87 : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: isPrompt ? Colors.black54 : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// Flashcard Page to display flashcards
class FlashcardPage extends StatelessWidget {
  final List<Flashcard> flashcards;

  const FlashcardPage({super.key, required this.flashcards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flashcards")),
      body: ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = flashcards[index];
          return Card(
            margin: const EdgeInsets.all(10),
            color: flashcard.backgroundColor,
            child: ListTile(
              title: Text(flashcard.question),
              subtitle: Text(flashcard.answer),
            ),
          );
        },
      ),
    );
  }
}
