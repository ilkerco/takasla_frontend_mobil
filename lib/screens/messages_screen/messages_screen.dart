import 'package:flutter/material.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:takasla/models/ChatResponseModel.dart';
import 'package:takasla/models/Chats.dart';
import 'package:takasla/screens/messages_screen/messages_screen_body.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/CreateChatModel.dart';
import 'package:takasla/models/ChatMessages.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:provider/provider.dart';
import 'package:takasla/notifiers/user_notifier.dart';

class MessagesScreen extends StatefulWidget {
  final Product? targetProduct;
  final Product? suggestedProduct;
  final User? productOwner;

  const MessagesScreen(
      {Key? key,
      @required this.targetProduct,
      this.suggestedProduct,
      @required this.productOwner})
      : super(key: key);
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final serverUrl = "http://10.0.2.2:5000/chatHub";
  late HubConnection hubConnection;
  ChatMessages? chatMessages;
  @override
  void initState() {
    /*hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.onclose(({error}) {
      print('Connection close' + error.toString());
    });*/

    super.initState();
  }

  Future<ChatMessages> _loadMessages() async {
    String? hubConnectionId;
    print(1);
    await hubConnection
        .start()!
        .then((value) => hubConnection.invoke("GetConnectionId").then((value) {
              hubConnectionId = value.toString();
              print(hubConnectionId);
              print(2);
            }));
    print(3);
    return await createChat(
        new CreateChatModel(
            connectionId: hubConnectionId,
            toId: widget.productOwner!.id,
            suggestedProductId: widget.suggestedProduct == null
                ? null
                : widget.suggestedProduct!.id,
            targetProductId: widget.targetProduct!.id),
        Provider.of<UserNotifier>(context, listen: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: Border(
              bottom:
                  BorderSide(color: Colors.grey.withOpacity(0.6), width: 0.6)),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back_ios)),
              SizedBox(width: 10),
              CircleAvatar(
                backgroundImage: NetworkImage(widget.productOwner!.photoUrl!),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productOwner!.displayName!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Text("Active 3m ago",
                      style: TextStyle(color: Colors.grey, fontSize: 12))
                ],
              )
            ],
          ),
        ),
        body: FutureBuilder(
          future: getSingleChat(
              Provider.of<UserNotifier>(context, listen: false),
              widget.targetProduct!.id!),
          //_loadMessages()
          /* createChat(
                  new CreateChatModel(
                      connectionId: "hubConnectionId",
                      toId: widget.productOwner!.id,
                      suggestedProductId: widget.suggestedProduct == null
                          ? null
                          : widget.suggestedProduct!.id,
                      targetProductId: widget.targetProduct!.id),
                  Provider.of<UserNotifier>(context, listen: false))*/
          builder: (BuildContext context,
              AsyncSnapshot<ChatResponseModel> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                );
              default:
                if (snapshot.hasError)
                  return Text('Error ${snapshot.error}');
                else
                  return MessagesScreenBody(
                    productOwner: widget.productOwner,
                    suggestedProduct: widget.suggestedProduct,
                    targetProduct: widget.targetProduct,
                    chatResponseModel: snapshot.data,
                  );
            }
          },
        ) /*MessagesScreenBody(
          productOwner: widget.productOwner,
          suggestedProduct: widget.suggestedProduct,
          targetProduct: widget.targetProduct,
          chatMessages: chatMessages,
        )*/
        );
  }
}
