import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();

    void _resetPassword() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $email!')),
        );

        // Navigate to the Reset Password Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 36, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            MaterialButton(
              minWidth: double.infinity,
              height: 50,
              onPressed: _resetPassword,
              color: Colors.teal,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
