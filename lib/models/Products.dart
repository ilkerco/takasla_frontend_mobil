class Product {
  int? id;
  String? ownerId;
  String? title, description, category;
  List? images;
  String? createdAt;
  double? longitude;
  double? latitude;
  int? cip;

  Product();
  Product.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    ownerId = data['ownerId'];
    title = data['title'];
    description = data['description'];
    category = data['category'];
    images = data['images'];
    createdAt = data['createdAt'];
    longitude = double.parse(data['longitude'].toString());
    latitude = double.parse(data['latitude'].toString());
    cip = data['price'];
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'images': images,
      'price': cip,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMapwithId() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'images': images,
      'createdAt': createdAt,
      'longitude': longitude,
      'latitude': latitude,
      'price': cip,
    };
  }
}
