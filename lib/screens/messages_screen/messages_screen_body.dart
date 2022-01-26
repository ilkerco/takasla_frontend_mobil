import 'package:flutter/material.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/models/ChatResponseModel.dart';
import 'package:takasla/models/Chats.dart';
import 'package:takasla/models/ChatMessage.dart';
import 'package:signalr_flutter/signalr_flutter.dart';
import 'package:takasla/models/ChatMessages.dart';
import 'package:takasla/models/CreateChatModel.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/root_screen/root_screen.dart';
import 'package:takasla/services/api/takasla_api.dart';

class MessagesScreenBody extends StatefulWidget {
  final Product? targetProduct;
  final Product? suggestedProduct;
  final User? productOwner;
  //final ChatMessages? chatMessages;
  final ChatResponseModel? chatResponseModel;

  const MessagesScreenBody(
      {Key? key,
      this.targetProduct,
      this.suggestedProduct,
      this.productOwner,
      this.chatResponseModel})
      : super(key: key);
  @override
  _MessagesScreenBodyState createState() => _MessagesScreenBodyState();
}

class _MessagesScreenBodyState extends State<MessagesScreenBody> {
  final serverUrl = "https://ilkersargin.site/chatHub";
  final messageTextController = TextEditingController();
  late HubConnection hubConnection;
  String _signalRStatus = 'Unknown';
  late SignalR signalR;
  late String connectionId;
  @override
  void initState() {
    super.initState();
    initSignalR();
    //initPlatformState();
  }

  void initSignalR() async {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.onclose(({error}) {
      print('Connection close' + error.toString());
    });
    hubConnection.on("ReceiveMessage", _updateScreen);
    /*hubConnection.on("ReceiveMessage", (arguments) {
      print("selammsms");
      print(arguments![0].toString());
      print(arguments[1].toString());
      print(arguments[2].toString());
      widget.chatResponseModel!.messages!.add(Messages(
          name: arguments[0].toString(),
          text: arguments[1].toString(),
          timeStamp: "16:58"));
      messageTextController.clear();
      setState(() {});
    });*/
    hubConnection
        .start()!
        .then((value) => hubConnection.invoke("GetConnectionId").then((value) {
              connectionId = value.toString();
              if (widget.chatResponseModel != null) {
                hubConnection.invoke("JoinRoom",
                    args: <Object>[widget.chatResponseModel!.chatName!]);
              }
            }));
  }

  void _updateScreen(List<Object>? parameters) {
    messageTextController.clear();
    widget.chatResponseModel!.messages!.insert(
        0,
        Messages(
            name: parameters![0].toString(),
            text: parameters[1].toString(),
            timeStamp: "16:58"));
    setState(() {});
  }

  Future<void> initPlatformState() async {
    signalR = SignalR('http://10.0.2.2:5000', "chatHub",
        hubMethods: ["ReceiveMessage"],
        statusChangeCallback: _onStatusChange,
        hubCallback: _onNewMessage);
    await signalR.connect();
  }

  _onStatusChange(dynamic status) {
    if (mounted) {
      setState(() {
        _signalRStatus = status as String;
        print(_signalRStatus);
      });
    }
  }

  _onNewMessage(String? methodName, dynamic message) {
    print("asdasdasdads");
    print(
        'MethodName************ = $methodName, Message**************** = $message');
  }

  _handleNewMessages(List<Object>? message) {
    print("yeni mesah var" + message![0].toString());
    setState(() {});
  }

  Future<void> _getConnectionId() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      hubConnection.invoke("GetConnectionId").then((value) {
        connectionId = value.toString();
      });
    } else {
      hubConnection.start()!.then(
          (value) => hubConnection.invoke("GetConnectionId").then((value) {
                connectionId = value.toString();
              }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                            image: NetworkImage(
                                widget.targetProduct!.images![0]))),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                      //SimpleLineIcons.refresh,
                      Icons.refresh,
                      size: 16,
                      color: Colors.grey),
                  SizedBox(
                    width: 5,
                  ),
                  widget.suggestedProduct != null
                      ? Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  image: NetworkImage(chatsData[0].image))),
                        )
                      : Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey[200]),
                          child: Icon(
                            //AntDesign.question,
                            Icons.question_answer,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ),
                  SizedBox(
                    width: 7,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.targetProduct!.title!,
                          style: TextStyle(fontSize: 13)),
                      widget.suggestedProduct == null
                          ? Text(
                              "Not choosed",
                              style: TextStyle(fontSize: 13),
                            )
                          : Text("title 2", style: TextStyle(fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[200],
                child: ListView.builder(
                    reverse: true,
                    itemCount: widget.chatResponseModel!.messages!.length +
                        1, //demoChatMessages.length,
                    itemBuilder: (context, index) {
                      if (index == widget.chatResponseModel!.messages!.length) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.6),
                                  width: 0.6),
                              color: Colors.white),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "1.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " Suggest your good or coins for swap",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "2.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " Discuss details",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "3.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " Exchange goods in person or via delivery",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "4.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " Close the deal and get +1 to success deals",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Message(
                            message:
                                widget.chatResponseModel!.messages![index]);
                      }
                    }),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(
                          color: Colors.grey.withOpacity(0.6), width: 0.6))),
              child: Row(
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  Icon(Icons.mic, color: kPrimaryColor),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Container(
                    color: Colors.white,
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: messageTextController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              hintText: "Type message",
                              border: InputBorder.none),
                        )),
                        InkWell(
                          onTap: () async {
                            if (messageTextController.text.isNotEmpty) {
                              if (connectionId.isEmpty) {
                                await _getConnectionId();
                              }
                              await sendMessage(
                                      CreateChatModel(
                                          targetProductId:
                                              widget.targetProduct!.id,
                                          suggestedProductId: null,
                                          messageText:
                                              messageTextController.text,
                                          toId: widget.productOwner!.id,
                                          connectionId: connectionId),
                                      Provider.of<UserNotifier>(context,
                                          listen: false))
                                  .then((value) {
                                if (value) {
                                  /*widget.chatResponseModel!.messages!.add(
                                      Messages(
                                          name: Provider.of<UserNotifier>(
                                                  context,
                                                  listen: false)
                                              .CurrentUser!
                                              .id,
                                          text: messageTextController.text,
                                          timeStamp: "16:58"));*/
                                  //setState(() {});
                                  //messageTextController.clear();
                                }
                              });
                            }

                            /*if (hubConnection.state ==
                                HubConnectionState.Disconnected) {
                              await hubConnection.start();
                            }
                            await hubConnection
                                .invoke("JoinRoom", args: <Object>["yeni oda"]);*/

                            /*sendMessage(
                                "ilker",
                                9,
                                Provider.of<UserNotifier>(context,
                                    listen: false));*/
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: kPrimaryColor),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.send, color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Message extends StatelessWidget {
  const Message({
    Key? key,
    @required this.message,
  }) : super(key: key);
  final Messages? message;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message!.name ==
              Provider.of<UserNotifier>(context, listen: false)
                  .CurrentUser!
                  .id
                  .toString()
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
              color: message!.name ==
                      Provider.of<UserNotifier>(context, listen: false)
                          .CurrentUser!
                          .id
                          .toString()
                  ? Colors.grey[400]!.withOpacity(0.6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10, left: 10, right: 10),
            child: Text(
              message!.text!,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        message!.name ==
                Provider.of<UserNotifier>(context, listen: false)
                    .CurrentUser!
                    .id
                    .toString()
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "16:58",
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.grey,
                  )
                ],
              )
            : Container(),
      ],
    );
  }
}
