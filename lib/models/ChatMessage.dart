import 'package:flutter/material.dart';

enum ChatMessageType { text, audio, image, video }
enum MessageStatus { not_sent, not_view, viewed }

class ChatMessage {
  final String? text;
  final ChatMessageType? messageType;
  final MessageStatus? messageStatus;
  final bool? isSender;
  ChatMessage({this.isSender, this.messageStatus, this.messageType, this.text});
}

List demoChatMessages = [
  ChatMessage(
      text: "Selam",
      isSender: false,
      messageStatus: MessageStatus.viewed,
      messageType: ChatMessageType.text),
  ChatMessage(
      text: "Selam",
      isSender: true,
      messageStatus: MessageStatus.viewed,
      messageType: ChatMessageType.text),
  ChatMessage(
      text: "Kolu kaça bırakırsın ? ",
      isSender: false,
      messageStatus: MessageStatus.viewed,
      messageType: ChatMessageType.text),
  ChatMessage(
      text: "Pazarlık yaparız aga",
      isSender: true,
      messageStatus: MessageStatus.viewed,
      messageType: ChatMessageType.text),
];
