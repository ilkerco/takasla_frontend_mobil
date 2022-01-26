import 'package:flutter/material.dart';

class ChatMessages {
  int? chatId;
  String? chatName;
  List? messages;
  ChatMessages();
  ChatMessages.fromMap(Map<String, dynamic> data) {
    chatId = data['chatId'];
    chatName = data['chatName'];
    messages = data['messages'];
  }
  Map<String, dynamic> toMap() {
    return {'chatId': chatId, 'messages': messages, 'chatName': chatName};
  }
}
