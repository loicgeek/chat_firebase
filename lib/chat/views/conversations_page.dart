import 'package:chat_firebase/auth/auth_provider.dart';
import 'package:chat_firebase/chat/views/conversation_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({Key? key}) : super(key: key);

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  User _user = FirebaseAuth.instance.currentUser!;

  CollectionReference _usersRef =
      FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Bienvenue ${_user.displayName}"),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs.map((e) => e.data()).toList();
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var user = data[index]! as Map<String, dynamic>;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: user['id'] == _user.uid
                          ? Container(
                              height: 20,
                              width: 20,
                              color: Colors.green,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context)
                            .push(ConversationDetailsPage.chatWith(user));
                      },
                      title: Text("${user['name']}"),
                    ),
                    Divider(height: 1),
                  ],
                );
              },
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container();
        },
      ),
    );
  }
}
