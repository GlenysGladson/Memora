import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Show loading spinner during sign-up

  // Firebase Sign Up method
  Future<void> _signUp() async {
    print("here-1");
    if (_formKey.currentState!.validate()) {
      print("Sign Up Button Pressed"); // Debugging message
      setState(() {
        _isLoading = true;
      });

      try {
        print("here-2");
        // Sign up the user using Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        print("User created: ${userCredential.user?.email}"); // Debugging message

        // After successful signup, show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-Up Successful!')),
        );

        // Navigate to another screen (e.g., home page)
        Navigator.pop(context); // Going back to the previous screen (or you can navigate to another page)
      } on FirebaseAuthException catch (e) {
        // Handle Firebase Authentication errors
        print("Error during sign up: ${e.code}"); // Debugging message
        String errorMessage = 'An error occurred, please try again later.';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email is already in use.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else {
          errorMessage = 'Error: ${e.code} - ${e.message}';
        }

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Handle other errors
        print("Unexpected error: $e"); // Debugging message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Sign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Loading spinner or sign-up button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : MaterialButton(
                            minWidth: double.infinity,
                            height: 50,
                            onPressed: _signUp,
                            color: Colors.teal,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
