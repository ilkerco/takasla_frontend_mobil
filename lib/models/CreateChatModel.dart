import 'package:flutter/material.dart';

class CreateChatModel {
  String? toId;
  String? connectionId;
  String? messageText;
  int? targetProductId;
  int? suggestedProductId;

  CreateChatModel(
      {this.connectionId,
      this.suggestedProductId,
      this.targetProductId,
      this.messageText,
      this.toId});
  Map<String, dynamic> toMap() {
    return {
      'toId': toId,
      'targetProductId': targetProductId,
      'suggestedProductId': suggestedProductId,
      'connectionId': connectionId,
      'messageText': messageText
    };
  }
}
