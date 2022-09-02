import 'package:flutter/material.dart';
import 'package:flashchad/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late User loggedInUser;
final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = '/ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final textEditingController = TextEditingController();
  late String senderMessage;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void addMessage(String text) async {
    _firestore.collection('bible').add({
      'sinner': loggedInUser.email,
      'sins': text,
      'time': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Center(child: Text('⚡️Chat')),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        senderMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      textEditingController.clear();
                      addMessage(senderMessage);
                      // _firestore.collection('bible').add({'sinner': loggedInUser.email, 'sins': senderMessage});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool checkSender;
  const MessageBubble({required this.text, required this.sender, required this.checkSender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: (checkSender) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Color(0xFFF8F0E3),
            ),
          ),
          Material(
            color: (checkSender) ? Colors.lightBlueAccent : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: (checkSender) ? Radius.circular(30.0) : Radius.circular(0.0),
              bottomRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              topRight: (checkSender) ? Radius.circular(0) : Radius.circular(30.0),
            ),
            elevation: 5.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                text,
                style: TextStyle(fontSize: 20.0, color: (checkSender) ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bible').orderBy('time', descending: false).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
        final messagesFirebase = snapshot.data?.docs.reversed;
        List<MessageBubble> messageWidgets = [];
        for (var i in messagesFirebase!) {
          Map<String, dynamic> contents = (i.data()! as Map<String, dynamic>);
          final messageText = contents['sins'];
          final messageSender = contents['sinner'];
          final messageWidget = MessageBubble(
            text: messageText,
            sender: messageSender,
            checkSender: (messageSender == loggedInUser.email),
          );
          messageWidgets.add(messageWidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageWidgets,
          ),
        );
      },
    );
  }
}
