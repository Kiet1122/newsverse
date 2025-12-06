import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsverse/models/api/api_article.dart';
import 'package:newsverse/models/article_model.dart';
import '../../constants/api_constants.dart';
import '../../../models/api/news_response.dart';

class NewsApiService {
  Future<List<ArticleModel>> fetchTopHeadlines() async {
    final url = Uri.parse(
      "https://newsapi.org/v2/top-headlines?country=us&apiKey=${ApiConstants.newsApiKey}",
    );

    final response = await http.get(url);

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List articles = data['articles'];

      return articles.map((json) {
        final apiArticle = ApiArticle.fromJson(json);
        return ArticleModel.fromApiArticle(apiArticle);
      }).toList();
    } else {
      throw Exception("Lỗi tải tin từ API");
    }
  }

  /// Fetches news articles from the NewsAPI based on category
  Future<NewsResponse> fetchNews({String category = 'general'}) async {
    try {
      final url =
          '${ApiConstants.newsBaseUrl}/top-headlines?country=us&category=$category&apiKey=${ApiConstants.newsApiKey}';
      print('Fetching news from: $url');

      final response = await http.get(Uri.parse(url));

      print('Response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API success - Status: ${data['status']}');
        print('Total results: ${data['totalResults']}');
        print('Number of articles: ${data['articles']?.length ?? 0}');

        if (data['articles'] != null && data['articles'].isNotEmpty) {
          print('First article: ${data['articles'][0]['title']}');
        }

        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('Error 401: Invalid API key');
        throw Exception('API key không hợp lệ hoặc đã hết hạn');
      } else if (response.statusCode == 429) {
        print('Error 429: Too many requests');
        throw Exception('Đã vượt quá giới hạn request API');
      } else {
        print('API error ${response.statusCode}: ${response.body}');
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      print('NewsAPI connection error: $e');
      throw Exception('Không thể kết nối đến NewsAPI: $e');
    }
  }

  /// Searches for news articles based on query string
  Future<NewsResponse> searchNews(String query) async {
    try {
      final url =
          '${ApiConstants.newsBaseUrl}/everything?q=$query&pageSize=50&sortBy=relevancy&apiKey=${ApiConstants.newsApiKey}';
      print('Searching API: $url');

      final response = await http.get(Uri.parse(url));

      print('Search API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Search successful - Total results: ${data['totalResults']}');
        print('Search articles found: ${data['articles']?.length ?? 0}');
        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('Search API error: Invalid API key');
        throw Exception('API key không hợp lệ hoặc đã hết hạn');
      } else if (response.statusCode == 429) {
        print('Search API error: Too many requests');
        throw Exception('Đã vượt quá giới hạn request API');
      } else {
        print('Search API error ${response.statusCode}: ${response.body}');
        throw Exception('Lỗi tìm kiếm: ${response.statusCode}');
      }
    } catch (e) {
      print('Search connection error: $e');
      throw Exception('Không thể kết nối đến NewsAPI: $e');
    }
  }
}
