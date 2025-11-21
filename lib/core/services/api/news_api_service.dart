import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';
import '../../../models/api/news_response.dart';

// Service để gọi API lấy tin tức
class NewsApiService {
  
  // Lấy tin tức theo danh mục
  // category: loại tin (chung, kinh doanh, công nghệ, thể thao...)
  // mặc định là tin chung
  Future<NewsResponse> fetchNews({String category = 'general'}) async {
    try {
      // Tạo URL để gọi API
      final url = '${ApiConstants.newsBaseUrl}/top-headlines?country=us&category=$category&apiKey=${ApiConstants.newsApiKey}';
      print('Đang lấy tin từ: $url');
      
      // Gửi request đến API
      final response = await http.get(Uri.parse(url));

      print('Mã phản hồi: ${response.statusCode}');
      
      // Kiểm tra kết quả
      if (response.statusCode == 200) {
        // Chuyển đổi dữ liệu JSON
        final data = json.decode(response.body);
        print('API thành công - Trạng thái: ${data['status']}');
        print('Tổng số kết quả: ${data['totalResults']}');
        print('Số bài viết: ${data['articles']?.length ?? 0}');
        
        // In bài viết đầu tiên để kiểm tra
        if (data['articles'] != null && data['articles'].isNotEmpty) {
          print('Bài viết đầu tiên: ${data['articles'][0]['title']}');
        }
        
        // Trả về dữ liệu đã xử lý
        return NewsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('Lỗi 401: API key không hợp lệ');
        throw Exception('API key không hợp lệ hoặc đã hết hạn');
      } else if (response.statusCode == 429) {
        print('Lỗi 429: Quá nhiều request');
        throw Exception('Đã vượt quá giới hạn request API');
      } else {
        print('Lỗi API ${response.statusCode}: ${response.body}');
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối NewsAPI: $e');
      throw Exception('Không thể kết nối đến NewsAPI: $e');
    }
  }

  // Tìm kiếm tin tức theo từ khóa
  // query: từ khóa cần tìm
  Future<NewsResponse> searchNews(String query) async {
    try {
      // Tạo URL tìm kiếm
      final url = '${ApiConstants.newsBaseUrl}/everything?q=$query&apiKey=${ApiConstants.newsApiKey}';
      print('Đang tìm kiếm: $url');
      
      // Gửi request tìm kiếm
      final response = await http.get(Uri.parse(url));

      print('Mã phản hồi tìm kiếm: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Lỗi tìm kiếm: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi tìm kiếm: $e');
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }
}