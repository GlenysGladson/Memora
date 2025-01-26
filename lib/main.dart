import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'reset_password_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/home.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyAMski3kKtxQ9MofPO6yOFoMCUup4xKBkE", appId: 
"1:358807484328:android:7e9fddd82f1541e3524f9d", messagingSenderId:
   "358807484328", projectId: "memora-8aa71"));
  }catch(e){
    print('Initialize not Done');
  }
  
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & Sign Up',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
