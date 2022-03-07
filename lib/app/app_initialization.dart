import 'package:chat_firebase/auth/views/login_page.dart';
import 'package:chat_firebase/chat/views/conversations_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppInititialization extends StatefulWidget {
  const AppInititialization({Key? key}) : super(key: key);

  @override
  _AppInititializationState createState() => _AppInititializationState();
}

class _AppInititializationState extends State<AppInititialization> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return ConversationsPage();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
