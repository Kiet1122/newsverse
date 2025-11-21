// Enum để xác định nguồn gốc của bài viết
enum ArticleSource {
  firebase,    // Bài viết từ Firebase database
  api,         // Bài viết từ API bên ngoài
  journalist,  // Bài viết từ nhà báo trong hệ thống
}

// Extension để thêm tính năng cho enum
extension ArticleSourceExt on ArticleSource {
  // Chuyển enum thành tên dạng string
  String get name {
    switch (this) {
      case ArticleSource.firebase:
        return 'firebase';
      case ArticleSource.api:
        return 'api';
      case ArticleSource.journalist:
        return 'journalist';
    }
  }

  // Chuyển từ string sang enum
  static ArticleSource fromString(String s) {
    switch (s) {
      case 'api':
        return ArticleSource.api;
      case 'journalist':
        return ArticleSource.journalist;
      default:
        return ArticleSource.firebase; // Mặc định là firebase
    }
  }
}