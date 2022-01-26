class ImageUrlList {
  List? images;

  ImageUrlList();
  ImageUrlList.fromMap(Map<String, dynamic> data) {
    images = data['images'];
  }
  Map<String, dynamic> toMap() {
    return {
      'images': images,
    };
  }
}
