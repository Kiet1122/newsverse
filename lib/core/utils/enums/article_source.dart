enum ArticleSource {
  firebase,   
  api,        
  journalist, 
}

extension ArticleSourceExt on ArticleSource {
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

  static ArticleSource fromString(String s) {
    switch (s) {
      case 'api':
        return ArticleSource.api;
      case 'journalist':
        return ArticleSource.journalist;
      default:
        return ArticleSource.firebase; 
    }
  }
}