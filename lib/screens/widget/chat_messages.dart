import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/widget/message_bubble.dart';
import 'package:flutter_application_1/screens/widget/new_message.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              'No messages found. Start adding some!',
            ));
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('An error occurred. Please try again later.',
                    style: TextStyle(color: Colors.red)));
          }
          if (snapshot.hasData) {
            final chatDocs = snapshot.data!.docs;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) {
                      final chatDoc = chatDocs[index].data();
                      final nextChatDoc = index + 1 < chatDocs.length
                          ? chatDocs[index + 1].data()
                          : null;
                      final currentMessageUserId = chatDoc['userId'];

                      final nextMessageUserId =
                          nextChatDoc != null ? nextChatDoc['userId'] : null;

                      final isFirstInSequence =
                          currentMessageUserId != nextMessageUserId;
                      if (isFirstInSequence) {
                        return MessageBubble.next(
                            message: chatDoc['text'],
                            isMe: chatDoc['userId'] ==
                                FirebaseAuth.instance.currentUser!.uid);
                      } else {
                        return MessageBubble.first(
                          key: ValueKey(chatDocs[index].id),
                          message: chatDoc['text'],
                          username: chatDoc['username'],
                          userImage: chatDoc['userImage'],
                          isMe: chatDoc['userId'] ==
                              FirebaseAuth.instance.currentUser!.uid,
                        );
                      }
                    },
                  ),
                ),
                const NewMessage(),
              ],
            );
          }

          return const Column(
            children: [
              Expanded(
                child: Center(
                  child: Text('No messages found. Start adding some!'),
                ),
              ),
              NewMessage(),
            ],
          );
        });
  }
}
