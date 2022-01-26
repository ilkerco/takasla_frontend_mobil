import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takasla/models/ChatResponseModel.dart';
import 'package:takasla/models/Chats.dart';
import 'package:takasla/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:takasla/screens/messages_screen/messages_screen.dart';
import 'package:takasla/services/api/takasla_api.dart';
import 'package:takasla/size_config.dart';

class ChatScreenBody extends StatefulWidget {
  @override
  _ChatScreenBodyState createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<ChatScreenBody> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          FutureBuilder(
              future: getUsersAllChats(
                  Provider.of<UserNotifier>(context, listen: false)),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ChatResponseModel>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .4),
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Text('Error ${snapshot.error}');
                    else
                      return Expanded(child: ChatWidget(snapshot.data));
                }
              }),
          /*Expanded(
            child: ListView.builder(
                itemCount: chatsData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MessagesScreen()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15.75),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      NetworkImage(chatsData[index].image)),
                              if (chatsData[index].isActive)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    height: 16,
                                    width: 16,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3)),
                                  ),
                                )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chatsData[index].name,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Opacity(
                                    opacity: 0.64,
                                    child: Text(
                                      chatsData[index].lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Opacity(
                              opacity: 0.64, child: Text(chatsData[index].time))
                        ],
                      ),
                    ),
                  );
                }),
          ),*/
        ],
      ),
    );
  }

  Widget ChatWidget(List<ChatResponseModel>? chats) {
    if (chats == null || chats.isEmpty) {
      return Text("Henüz chatiniz yok");
    }
    return ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              var targetProduct = Provider.of<ProductNotifier>(context,
                      listen: false)
                  .productList
                  .singleWhere(
                      (element) => element.id == chats[index].targetProductId);
              var owner = await getUserByIdd(chats[index].toId.toString(),
                  Provider.of<UserNotifier>(context, listen: false));
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return MessagesScreen(
                  productOwner: owner,
                  targetProduct: targetProduct,
                  suggestedProduct: null,
                );
              }));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 15),
                        height: getProportionateScreenHeight(80),
                        decoration: new BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  "https://www.arthenos.com/wp-content/uploads/2017/08/Manzara_fotografciligi_2-696x522.jpg"),
                              fit: BoxFit.fill),
                          color: Colors.green,
                          border: Border.all(color: Colors.black, width: 0.0),
                          borderRadius:
                              new BorderRadius.all(Radius.elliptical(25, 25)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: getProportionateScreenHeight(15),
                                backgroundImage: NetworkImage(
                                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                flex: 4,
                                child: Text(
                                  chats[index].fromId.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "17 Ocak 2022",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: getProportionateScreenHeight(7),
                                      ),
                                      Text(
                                        chats[index]
                                            .messages![
                                                chats[index].messages!.length -
                                                    1]
                                            .text
                                            .toString(),
                                        overflow: TextOverflow.ellipsis
                                        /*chats[index]
                                .messages![chats[index].messages!.length - 1]
                                .text
                                .toString()*/
                                        ,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: getProportionateScreenHeight(7),
                                      ),
                                      Text(
                                        "Takas önerisi",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      )
                                    ],
                                  )),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: getProportionateScreenHeight(2)),
                                  height: getProportionateScreenHeight(50),
                                  decoration: new BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            "https://www.arthenos.com/wp-content/uploads/2017/08/Manzara_fotografciligi_2-696x522.jpg"),
                                        fit: BoxFit.fill),
                                    color: Colors.green,
                                    borderRadius: new BorderRadius.all(
                                        Radius.elliptical(15, 15)),
                                  ),
                                ),
                              )
                            ],
                          )
                          /*SizedBox(
                            height: getProportionateScreenHeight(7),
                          ),
                          Text(
                            "Selam sana bir teklifim var asdasdasdsad",
                            overflow: TextOverflow.ellipsis
                            /*chats[index]
                                .messages![chats[index].messages!.length - 1]
                                .text
                                .toString()*/
                            ,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(7),
                          ),
                          Text(
                            "Takas önerisi",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          )*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
