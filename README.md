📰 Báo cáo tuần 2 – Dự án NewsVerse (08/11 – 14/11)
Tuần 2 tập trung vào việc chuẩn bị kiến trúc dự án và xây dựng giao diện cơ bản cho ứng dụng đọc tin tức cá nhân hóa.  

🎯 Mục tiêu tuần
- 🏗 Thiết kế kiến trúc project và cấu trúc thư mục Flutter theo mô hình chuẩn.
- 🔄 Phân tích luồng chức năng chính và mối liên hệ giữa các màn hình.
- 🎨 Tham khảo UI/UX từ các app News phổ biến (Báo Mới, Zing News, Google News) để xác định phong cách thiết kế.
- 💻 Khởi tạo repository GitHub và đẩy project Flutter lên quản lý mã nguồn.
- 📱 Xây dựng giao diện cơ bản cho các màn hình: Đăng nhập, Đăng ký, Trang chủ.
- 🔐 Thiết lập Firebase Authentication và kiểm tra đăng nhập cơ bản.

📂 Cấu trúc thư mục Flutter
Cấu trúc thư mục đã được thiết kế theo mô hình **feature + presentation + viewmodel + data**:
```
lib/
├── core/
│   ├── constants/
│   ├── utils/
│   ├── theme/
│   ├── widgets/
│   └── services/
│
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   ├── viewmodel/
│   │   └── data/
│   ├── news/
│   ├── journalist/
│   ├── admin/
│   ├── profile/
│   └── notification/
│
├── main.dart
├── firebase_options.dart
└── routes/
```
> Mỗi feature tách biệt giữa UI (`presentation`), logic (`viewmodel`) và dữ liệu (`data`) để dễ quản lý.

🔄 Luồng chức năng và mối liên hệ màn hình
👥 Actor
1. **User**: Đăng ký/Đăng nhập, đọc tin, bookmark, xem trang cá nhân.  
2. **Journalist**: Đăng bài, chỉnh sửa bài viết.  
3. **Admin**: Quản lý bài viết và người dùng.  

🗺 Luồng cơ bản
- Đăng nhập/Đăng ký → kiểm tra Firebase Auth → Trang chủ.  
- Trang chủ → danh sách tin → chọn bài → Chi tiết bài viết.  
- Bookmark/Like/Comment → cập nhật Firestore.  
- Admin/Journalist → truy cập màn hình quản lý riêng.  
> Dự kiến toàn dự án gồm **23 màn hình**.

🎨 Tham khảo UI/UX
- **Nguồn tham khảo**: Báo Mới, Zing News, Google News  
- **Quy tắc thiết kế**:  
  - Cuộn dọc, Card hiển thị bài viết lớn/nhỏ.  
  - Bottom Navigation Bar: Tin tức, Video, Xu hướng, Cá nhân.  
  - Header rõ ràng, phân cấp thông tin trực quan.  

📱 Giao diện cơ bản đã triển khai
- **LoginScreen**: Email, Password, nút Đăng nhập.  
- **RegisterScreen**: Email, Password, nút Đăng ký, chuyển sang LoginScreen.  
- **HomeScreen**: Scaffold với AppBar, danh sách tin mẫu.

🔐 Firebase Authentication
- Thiết lập Firebase Auth cho dự án Flutter.  
- Kiểm tra đăng nhập/đăng ký cơ bản hoạt động.  
- Người dùng mới được tạo trong Firebase Console.

💻 Quản lý mã nguồn
- Repository GitHub: [https://github.com/Kiet1122/newsverse](https://github.com/Kiet1122/newsverse)  
- Đã push toàn bộ source code cơ bản (`lib/features/auth`, `main.dart`, `firebase_options.dart`).  
- Commit đầu tiên chứa cấu trúc thư mục chuẩn và README.md tuần 2.

✅ Kết luận tuần 2
- Cấu trúc thư mục Flutter đã chuẩn hóa.  
- Giao diện cơ bản các màn hình hoạt động đúng.  
- Firebase Authentication hoạt động, đăng nhập/đăng ký thành công.  
- GitHub repository đã sẵn sàng cho các tính năng tuần 3.
