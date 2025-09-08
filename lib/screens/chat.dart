import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: const Color.fromARGB(255, 15, 28, 39),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              // Handle logout action
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Chat Screen!'),
      ),
    );
  }
}
