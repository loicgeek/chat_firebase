import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ConversationDetailsPage({Key? key, required this.user})
      : super(key: key);

  @override
  _ConversationDetailsPageState createState() =>
      _ConversationDetailsPageState();

  static chatWith(Map<String, dynamic> user) {
    return MaterialPageRoute(
      builder: (context) => ConversationDetailsPage(
        user: user,
      ),
    );
  }
}

class _ConversationDetailsPageState extends State<ConversationDetailsPage> {
  User _currentUser = FirebaseAuth.instance.currentUser!;
  late TextEditingController _messageController;
  CollectionReference _messagesRef =
      FirebaseFirestore.instance.collection("messages");

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String get conversationId {
    if (_currentUser.uid.hashCode < widget.user['id'].hashCode) {
      return "${_currentUser.uid}-${widget.user['id']}";
    }
    return "${widget.user['id']}-${_currentUser.uid}";
  }

  _onSend() async {
    if (_messageController.text.isNotEmpty) {
      _messagesRef.add({
        "conversation_id": conversationId,
        "message": _messageController.text,
        "from": _currentUser.uid,
        "to": widget.user['id'],
        "at": FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user["name"]}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesRef
                    .where("conversation_id", isEqualTo: conversationId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.docs
                        .map((e) => e.data() as Map<String, dynamic>)
                        .toList();
                    data.sort((a, b) {
                      return b['at'].compareTo(a['at']);
                    });

                    return ListView.builder(
                        reverse: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var message = data[index]! as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Row(
                              mainAxisAlignment:
                                  message['from'] == _currentUser.uid
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${message['message']}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                  }
                  return Container();
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ecrire",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _onSend,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
