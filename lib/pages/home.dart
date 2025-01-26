import 'package:flutter/material.dart';
import 'package:memora/pages/ai.dart';
import 'package:memora/pages/topics_page.dart';


class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home>{
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        padding: EdgeInsets.only(top: 90.0,left: 0.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [
          Color.fromARGB(244, 4, 103, 145),
          Color.fromARGB(244, 98, 183, 220),
          Color.fromARGB(244, 108, 239, 222)],
          begin: Alignment.topLeft,end: Alignment.bottomRight)),
        child: Column(
          children: [
            Text("Hello User!",style: TextStyle(
              color:Colors.white,
              fontSize: 25.0,
              fontWeight: FontWeight.bold)
              ),
            SizedBox(height: 10.0,),
            Text("Welcome to Memora!",style: TextStyle(
              color:Colors.white,
              fontSize: 25.0,
              fontWeight: FontWeight.w100)
              ),
              
            SizedBox(height: 90.0,),
              
            SizedBox(height: 50.0),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LearnWithAIPage()),
                );
              },
              backgroundColor: Color.fromARGB(255, 5, 110, 152),
              label: Text(
                "Learn With AI",
                style: TextStyle(fontSize: 20.0),
              ),
              icon: Icon(Icons.computer),
            ),
            SizedBox(height: 30.0),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopicsPage()),
                );
              },
              backgroundColor: Color.fromARGB(255, 5, 110, 152),
              label: Text(
                "Go For The Manual One",
                style: TextStyle(fontSize: 20.0),
              ),
              icon: Icon(Icons.book),
            ),
          ]
      ),
      ),
    );
  }
}

