import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:takasla/constants.dart';
import 'package:takasla/models/ChatResponseModel.dart';
import 'package:takasla/models/Products.dart';
import 'package:takasla/models/User.dart';
import 'package:takasla/models/CreateChatModel.dart';
import 'package:takasla/models/ImageUrlList.dart';
import 'package:takasla/models/ChatMessages.dart';
import 'package:takasla/notifiers/product_notifier.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

Future<User?> getCurrentUser(String accessToken) async {
  User? currentUser;
  try {
    var dio = Dio();
    Response response = await dio.get(
        localConnectionString + "/api/home/getCurrentUser",
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + accessToken
        }));
    currentUser = new User.fromMap(response.data);
    currentUser.accessToken = accessToken;
  } catch (e) {
    print(e.toString());
    currentUser = null;
  }
  return currentUser;
}

Future<void> getProducts(
    ProductNotifier productNotifier, UserNotifier userNotifier) async {
  var dio = Dio();
  Response response =
      await dio.get(localConnectionString + "/api/home/getAllProducts",
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
          }));
  final List rawData = jsonDecode(jsonEncode(response.data));
  List<Product> allProducts = rawData.map((e) => Product.fromMap(e)).toList();

  productNotifier.productList = allProducts;
}

/*GET PRODUCT BY ID LL BE USE AFTER
Future<Product> getProduct(UserNotifier userNotifier) async {
  var dio = Dio();
  Response response =
      await dio.get(localConnectionString + "/api/home/getAllProducts",
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
          }));
  final List rawData = jsonDecode(jsonEncode(response.data));
  List<Product> allProducts = rawData.map((e) => Product.fromMap(e)).toList();

  productNotifier.productList = allProducts;
}
*/
Future updateUser(UserNotifier userNotifier, User user) async {
  var dio = Dio();
  Response response =
      await dio.put(localConnectionString + "/api/home/updateUser/" + user.id!,
          data: user.toUpdateUserRequest(),
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
          }));
  if (response.statusCode == 200) {
    User updatedUser = new User.fromMap(response.data);
    userNotifier.setPhotoUrl = updatedUser.photoUrl!;
    userNotifier.setDisplayName = updatedUser.displayName!;
  }
}

getProductsByUser(User user, ProductNotifier productNotifier) async {
  var dio = Dio();
  Response response =
      await dio.get(localConnectionString + "/api/home/getCurrenUsersProducts",
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + user.accessToken!
          }));
  final List rawData = jsonDecode(jsonEncode(response.data));
  List<Product> allProducts = rawData.map((e) => Product.fromMap(e)).toList();
  productNotifier.usersProductList = allProducts;
}

Future<User> getUserById(Product product, UserNotifier userNotifier) async {
  var dio = Dio();
  Response response2 = await dio.get(
      localConnectionString + "/api/home/getUserById/" + product.ownerId!,
      options: Options(headers: {
        'content-type': 'application/JSON',
        'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
      }));
  User ownerUser = new User.fromMap(response2.data);
  userNotifier.productOwner = ownerUser;
  return ownerUser;
}

Future<User> getUserByIdd(String userId, UserNotifier userNotifier) async {
  var dio = Dio();
  Response response2 =
      await dio.get(localConnectionString + "/api/home/getUserById/" + userId,
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
          }));
  User ownerUser = new User.fromMap(response2.data);
  return ownerUser;
}

Future<bool> deleteSingleImage(String imgPath, String accesToken) async {
  var dio = Dio();
  try {
    Response response2 = await dio.delete(
        localConnectionString + "/api/home/deleteSingleImage",
        queryParameters: {"imageName": imgPath},
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + accesToken
        }));
    return true;
  } catch (e) {
    print("Delete Single Image failed!! " + e.toString());
    return false;
  }
}

Future<String?> uploadSingleImage(File img, UserNotifier userNotifier) async {
  var formData = new FormData();
  var uuid = Uuid().v4();
  var fileExtension = p.extension(img.path);
  var dio = Dio();
  formData.files.add(MapEntry("files",
      await MultipartFile.fromFile(img.path, filename: uuid + fileExtension)));
  try {
    Response response =
        await dio.post(localConnectionString + "/api/home/uploadImage",
            data: formData,
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization':
                  'Bearer ' + userNotifier.CurrentUser!.accessToken!
            }));
    String url = response.data["images"][0].toString();
    return url;
  } catch (e) {
    print("uploadSingleImage FAİLED!!  " + e.toString());
    return null;
  }
}

Future<ImageUrlList?> uploadImages(List<File> img, String accessToken) async {
  var formData = FormData();
  for (var file in img) {
    var uuid = Uuid().v4();
    var fileExtension = p.extension(file.path);

    formData.files.add(MapEntry(
        "files",
        await MultipartFile.fromFile(file.path,
            filename: uuid + fileExtension)));
  }
  var dio = Dio();
  try {
    Response response = await dio.post(
        localConnectionString + "/api/home/uploadImage",
        data: formData,
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + accessToken
        }));

    ImageUrlList images = new ImageUrlList.fromMap(response.data);
    return images;
  } catch (e) {
    print("uploadImages FAİLED!!  " + e.toString());
    return null;
  }
}

Future<String?> uploadSingleImageForProduct(
    File img, String accessToken) async {
  var uuid = Uuid().v4();
  var fileExtension = p.extension(img.path);
  var dio = Dio();
  FormData formData = FormData.fromMap({
    "file":
        await MultipartFile.fromFile(img.path, filename: uuid + fileExtension)
  });
  try {
    Response response = await dio.post(
        localConnectionString + "/api/home/uploadImage",
        data: formData,
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + accessToken
        }));
    String url = response.data.toString();
    return url;
  } catch (e) {
    print("uploadSingleImageForProduct FAİLED!! " + e.toString());
    return null;
  }
}

Future<Product> updateProduct(Product product, User user,
    ProductNotifier productNotifier, List<File> images2upload) async {
  Product oldProduct = new Product.fromMap(product.toMapwithId());
  product.images = List.empty();
  if (images2upload.length != 0) {
    ImageUrlList? imageUrls =
        await uploadImages(images2upload, user.accessToken!);
    product.images = imageUrls!.images;
  }

  var dio = Dio();
  try {
    Response response = await dio.put(
        localConnectionString +
            "/api/home/updateProduct/" +
            product.id.toString(),
        data: product.toMap(),
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + user.accessToken!
        }));

    Product updatedProduct = Product.fromMap(response.data);
    return updatedProduct;
  } catch (e) {
    print("updateProduct FAİLED!!!! " + e.toString());
    return oldProduct;
  }
}

Future<Product?> createProduct(
    UserNotifier userNotifier, Product product, List<File> images) async {
  product.images = [];
  ImageUrlList? imagesUrls =
      await uploadImages(images, userNotifier.CurrentUser!.accessToken!);
  var dio = Dio();
  product.images = imagesUrls!.images;
  try {
    Response response =
        await dio.post(localConnectionString + "/api/home/addProduct",
            data: product.toMap(),
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization':
                  'Bearer ' + userNotifier.CurrentUser!.accessToken!,
              'Connection': 'keep-alive'
            }));
    Product created = new Product.fromMap(response.data);
    return created;
  } catch (e) {
    print("Error while Creating Product  " + e.toString());
    return null;
  }
}

Future<ChatMessages> createChat(
    CreateChatModel chatModel, UserNotifier userNotifier) async {
  var dio = Dio();
  Response response2 =
      await dio.post(localConnectionString + "/api/chat/createChat",
          data: chatModel.toMap(),
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
          }));
  ChatMessages chatMessages = ChatMessages.fromMap(response2.data);
  return chatMessages;
}

Future<bool> sendMessage(
    CreateChatModel chatModel, UserNotifier userNotifier) async {
  var dio = Dio();
  try {
    Response response2 =
        await dio.post(localConnectionString + "/api/chat/sendMessage",
            data: chatModel.toMap(),
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization':
                  'Bearer ' + userNotifier.CurrentUser!.accessToken!
            }));
    return true;
  } catch (ex) {
    print("Error while Sending Message  " + ex.toString());
    return false;
  }
}

Future<void> createFirstChat(
    CreateChatModel chatModel, UserNotifier userNotifier) async {
  var dio = Dio();
  Response response2 =
      await dio.post(localConnectionString + "/api/chat/createChat",
          data: chatModel.toMap(),
          options: Options(headers: {
            'content-type': 'application/JSON',
            'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
          }));
}

Future<List<ChatResponseModel>> getUsersAllChats(
    UserNotifier userNotifier) async {
  var dio = Dio();
  try {
    Response response2 =
        await dio.get(localConnectionString + "/api/chat/getUserChats",
            options: Options(headers: {
              'content-type': 'application/JSON',
              'Authorization':
                  'Bearer ' + userNotifier.CurrentUser!.accessToken!
            }));
    final List rawData = jsonDecode(jsonEncode(response2.data));
    List<ChatResponseModel> allChats =
        rawData.map((e) => ChatResponseModel.fromJson(e)).toList();
    return allChats;
  } catch (e) {
    print("Error while gettin user chats" + e.toString());
    return [];
  }
}

Future<ChatResponseModel> getSingleChat(
    UserNotifier userNotifier, int targetProductId) async {
  var dio = Dio();
  try {
    Response response2 = await dio.get(
        localConnectionString +
            "/api/chat/getUserSingleChat/" +
            targetProductId.toString(),
        options: Options(headers: {
          'content-type': 'application/JSON',
          'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
        }));

    final rawData = jsonDecode(jsonEncode(response2.data));
    ChatResponseModel allChats = ChatResponseModel.fromJson(response2.data);
    allChats.messages = allChats.messages!.reversed.toList();
    return allChats;
  } catch (e) {
    print("Error while gettin user signle chats" + e.toString());
    return ChatResponseModel();
  }
}

/*Future<bool> sendMessage(
    String message, int chatId, UserNotifier userNotifier) async {
  var dio = Dio();
  Response response2 = await dio.post(
      localConnectionString +
          "/api/chatHub/sendMessage/" +
          message +
          "/" +
          chatId.toString(),
      options: Options(headers: {
        'content-type': 'application/JSON',
        'Authorization': 'Bearer ' + userNotifier.CurrentUser!.accessToken!
      }));
  return true;
}*/
