class ChatResponseModel {
  int? id;
  int? suggestedProductId;
  int? targetProductId;
  String? chatName;
  String? toId;
  String? fromId;
  List<Messages>? messages;

  ChatResponseModel(
      {this.id,
      this.suggestedProductId,
      this.targetProductId,
      this.chatName,
      this.toId,
      this.fromId,
      this.messages});

  ChatResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    suggestedProductId = json['suggestedProductId'];
    targetProductId = json['targetProductId'];
    chatName = json['chatName'];
    toId = json['toId'];
    fromId = json['fromId'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['suggestedProductId'] = this.suggestedProductId;
    data['targetProductId'] = this.targetProductId;
    data['chatName'] = this.chatName;
    data['toId'] = this.toId;
    data['fromId'] = this.fromId;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? name;
  String? text;
  String? timeStamp;

  Messages({this.name, this.text, this.timeStamp});

  Messages.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    text = json['text'];
    timeStamp = json['timeStamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['text'] = this.text;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
