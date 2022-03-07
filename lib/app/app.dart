import 'package:chat_firebase/app/app_initialization.dart';
import 'package:chat_firebase/auth/auth_provider.dart';
import 'package:chat_firebase/auth/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Application extends StatelessWidget {
  Application({Key? key}) : super(key: key);

  final AuthProvider _authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppInititialization(),
      ),
    );
  }
}
