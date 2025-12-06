# 📰 NewsVerse - Báo Cáo Dự Án Tuần 5

## ✅ Các Tính Năng Chính Đã Hoàn Thành

Dự án NewsVerse đã hoàn thiện với đầy đủ các tính năng cốt lõi và nâng cao, mang đến một trải nghiệm đọc tin tức toàn diện và có tính tương tác cao.

### 1. 🔐 Hệ thống Xác thực Người dùng (Authentication)
-   **Đăng ký & Đăng nhập:** Hỗ trợ đăng ký tài khoản mới và đăng nhập bằng email/password.
-   **Quên mật khẩu:** Chức năng cho phép người dùng lấy lại mật khẩu qua email.
-   **Tự động đăng nhập (Auto-login):** Giữ trạng thái đăng nhập của người dùng sau khi thoát ứng dụng.
-   **Đăng xuất:** Đảm bảo người dùng có thể đăng xuất khỏi tài khoản một cách an toàn.

### 2. 📰 Hệ thống Tin tức (News Feed)
-   **Tổng hợp tin tức đa nguồn:** Kết hợp dữ liệu từ **Firebase** (do người dùng đóng góp) và **NewsAPI** (tin tức toàn cầu).
-   **Loại bỏ trùng lặp:** Thuật toán thông minh tự động lọc và loại bỏ các bài viết trùng lặp.
-   **Phân loại tin tức:** Hiển thị tin tức theo các danh mục (Categories) rõ ràng.
-   **Chi tiết bài viết:** Cung cấp màn hình đọc báo đầy đủ nội dung, hình ảnh và thông tin liên quan.

### 3. 🎧 Tính năng Tiện ích & Tương tác
-   **Text-to-Speech (TTS):** Tích hợp chức năng đọc bài báo bằng giọng nói, giúp người dùng có thể "nghe" tin tức.
-   **Bình luận (Comments):** Cho phép người dùng thảo luận và chia sẻ ý kiến dưới mỗi bài viết.
-   **Thích (Likes):** Người dùng có thể bày tỏ sự yêu thích đối với các bình luận.
-   **Lưu bài viết (Bookmarks):** Chức năng lưu lại các bài viết quan tâm để đọc sau.

### 4. 🧭 Hệ thống Điều hướng & Giao diện
-   **Điều hướng chuyên nghiệp:** Sử dụng `named routes` để quản lý luồng di chuyển giữa các màn hình một cách rõ ràng và an toàn.
-   **Giao diện thân thiện:** Thiết kế các màn hình (Trang chủ, Chi tiết, Đăng nhập,...) trực quan, dễ sử dụng.

### 🏗️ Cập nhật kiến trúc

Kiến trúc ứng dụng được tổ chức theo từng tính năng (feature-based), giúp dễ dàng quản lý và mở rộng.

```
lib/
├───firebase_options.dart        
├───main.dart
│   
├───core
│   ├───constants
│   │       api_constants.dart   
│   │       
│   ├───layouts
│   │   │   main_layout.dart     
│   │   │
│   │   └───widgets
│   │           app_drawer.dart
│   │           bottom_nav_bar.dart
│   │
│   ├───services
│   │   ├───api
│   │   │       news_api_service.dart
│   │   │
│   │   ├───firebase
│   │   │       auth_service.dart
│   │   │       bookmark_service.dart
│   │   │       comment_service.dart
│   │   │       firestore_service.dart
│   │   │       like_service.dart
│   │   │
│   │   └───tts
│   │           tts_service.dart
│   │
│   └───utils
│       └───enums
│               article_source.dart
│   └───utils
│       └───enums
│               article_source.dart
│
├───features
│   ├───admin
│   │   ├───screens
│   │   └───widgets
│   ├───auth
│   │   │   auth_provider.dart
│   │   │
│   │   ├───screens
│   │   │       forgot_password_screen.dart
│   │   │       login_screen.dart
│   │   │       register_screen.dart
│   │   │
│   │   └───widgets
│   │           auth_button.dart
│   │           auth_text_field.dart
│   │
│   ├───bookmark
│   │   │   bookmark_provider.dart
│   │   │
│   │   └───screens
│   │           favorites_screen.dart
│   │
│   ├───home
│   │   │   home_provider.dart
│   │   │
│   │   ├───screens
│   │   │       home_screen.dart
│   │   │
│   │   └───widgets
│   │           category_chips.dart
│   │           news_card.dart
│   │           news_list.dart
│   │           personalized_news_list.dart
├───features
│   ├───admin
│   │   ├───screens
│   │   └───widgets
│   ├───auth
│   │   │   auth_provider.dart
│   │   │
│   │   ├───screens
│   │   │       forgot_password_screen.dart
│   │   │       login_screen.dart
│   │   │       register_screen.dart
│   │   │
│   │   └───widgets
│   │           auth_button.dart
│   │           auth_text_field.dart
│   │
│   ├───bookmark
│   │   │   bookmark_provider.dart
│   │   │
│   │   └───screens
│   │           favorites_screen.dart
│   │
│   ├───home
│   │   │   home_provider.dart
│   │   │
│   │   ├───screens
│   │   │       home_screen.dart
│   │   │
│   │   └───widgets
│   │           category_chips.dart
│   │           news_card.dart
│   │           news_list.dart
│   │           personalized_news_list.dart
│   │
│   ├───journalist
│   │   ├───screens
│   │   └───widgets
│   ├───news
│   │   ├───screens
│   │   │       news_detail_screen.dart
│   │   │
│   │   └───widgets
│   │           comment_section.dart
│   │           like_button.dart
│   │           tts_player.dart
│   │
│   ├───notification
│   │   ├───screens
│   │   └───widgets
│   ├───profile
│   │   │   profile_provider.dart
│   │   │
│   │   ├───screens
│   │   │       profile_screen.dart
│   │   │
│   │   └───widgets
│   │           bookmark_button.dart
│   │           preference_selector.dart
│   │
│   ├───search
│   │   └───screens
│   │           search_screen.dart
│   │
│   └───splash
│       └───screens
│               splash_screen.dart
│
├───models
│   │   article_interaction_model.dart
│   │   article_model.dart
│   │   bookmark_model.dart
│   │   category_model.dart
│   │   comment_model.dart
│   │   user_model.dart
│   │   user_preferences.dart
│   │
│   └───api
│           api_article.dart
│           news_response.dart
│
├───providers
│       app_provider.dart
│
└───routes
        app_routes.dart
        route_names.dart
```

### 📱 Demo tính năng mới

**1. Chi tiết bài viết với TTS Player**
![Comment](https://res.cloudinary.com/dmnkakpnb/image/upload/v1764956144/tuan5-3_yyeazq.png)

**2. Tương tác với bình luận (Thích và Xóa)**
![Comment](https://res.cloudinary.com/dmnkakpnb/image/upload/v1764956144/tuan_5-2_bfadbd.png)

**3. Màn hình quản home**
![Comment](https://res.cloudinary.com/dmnkakpnb/image/upload/v1764956144/tuan5-4_tfpzzw.pngg)

### 🎯 Kết luận Tuần 5

Việc bổ sung các tính năng tương tác đã biến NewsVerse từ một ứng dụng đọc tin tức đơn thuần thành một nền tảng tin tức cộng đồng. Người dùng giờ đây không chỉ tiêu thụ nội dung mà còn có thể tương tác với nội dung và với những người dùng khác.

-   ✅ **TTS** giúp ứng dụng dễ tiếp cận hơn.
-   ✅ **Bình luận & Thích** tăng cường sự gắn kết của người dùng.
-   ✅ **Lưu bài viết** cải thiện trải nghiệm cá nhân hóa.