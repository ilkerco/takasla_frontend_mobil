class Chat {
  final String? name, lastMessage, image, time;
  final bool? isActive;
  Chat({this.image, this.isActive, this.lastMessage, this.name, this.time});
}

List chatsData = [
  Chat(
      name: "Ilker",
      image:
          "https://ilkersargin.xyz/images/c9e509b9-5f13-412f-9144-f980f1a9c265.jpg",
      time: "3m ago",
      isActive: true,
      lastMessage: "selam"),
  Chat(
      name: "Gulden",
      image:
          "https://ilkersargin.xyz/images/c9e509b9-5f13-412f-9144-f980f1a9c265.jpg",
      time: "3m ago",
      isActive: false,
      lastMessage: "selam")
];
