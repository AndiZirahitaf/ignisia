class Course {
  String id;
  String title;
  String description;
  List<String> categories;
  int price;
  List<String> imageUrls;
  List<Lesson> lessons;
  bool owned;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.categories = const [],
    required this.price,
    required this.imageUrls,
    this.lessons = const [],
    this.owned = false,
  });
}

class Lesson {
  final String title;
  final String subtitle;
  final String content;
  final bool locked;
  bool completed;

  Lesson({
    required this.title,
    required this.subtitle,
    required this.content,
    this.completed = false,
    this.locked = false,
  });
}

List<Course> courseList = [
  Course(
    id: 'c1',
    title: 'Memulai Pemrograman Flutter',
    categories: ['Mobile', 'Programming', 'Flutter', 'Beginner'],
    price: 0,
    description:
        'Pelajari dasar-dasar Flutter untuk membangun aplikasi mobile lintas platform dengan tampilan modern. Cocok untuk pemula yang ingin masuk ke dunia mobile development.',
    imageUrls: [
      'https://flutter.dev/assets/homepage/carousel/slide_1-bg-2e111afbbc39bb1e8eac46f59b5e267c6d3f90c3e24e7d9f13c364b4c08170bb.jpg',
      'https://flutter.dev/assets/homepage/carousel/slide_1-layer_2-5d024c877307bfd2814c6f6da93f577b9b1cf27a5e2a87277bdc12a8e5dff3d0.png',
    ],
    owned: true,
    lessons: [
      Lesson(
        title: 'Pengenalan Flutter',
        subtitle: 'Apa itu Flutter dan mengapa menggunakannya?',
        content: '''
# Pengenalan Flutter

Flutter adalah framework open-source yang dikembangkan oleh Google untuk membangun aplikasi lintas platform menggunakan satu codebase.

**Keunggulan Flutter:**
- Satu codebase untuk Android dan iOS
- Performa tinggi
- UI konsisten
- Komunitas besar

> Flutter menggunakan bahasa **Dart** dan engine **Skia** untuk rendering cepat.

[Pelajari lebih lanjut di flutter.dev](https://flutter.dev)
''',
      ),
      Lesson(
        title: 'Environtment Setup',
        subtitle: 'Cara mengatur lingkungan pengembangan Flutter',
        content: '''
# Environment Setup

Sebelum mulai membuat aplikasi dengan Flutter, kamu perlu menyiapkan lingkungan pengembangannya terlebih dahulu. Proses ini memastikan semua alat yang dibutuhkan sudah terpasang dan siap digunakan.

Berikut langkah-langkahnya:

1. **Instal Flutter SDK**  
   - Unduh Flutter SDK di situs resmi [flutter.dev](https://flutter.dev/docs/get-started/install).  
   - Ekstrak ke direktori yang kamu inginkan (misalnya: `C:\\src\\flutter`).  
   - Tambahkan path `flutter\\bin` ke environment variables agar bisa diakses lewat terminal.

2. **Instal Android Studio**  
   Android Studio digunakan untuk mengembangkan, menjalankan emulator, dan mengelola SDK Android.  
   - Setelah instalasi, buka Android Studio → **Plugins** → cari dan aktifkan plugin *Flutter* (otomatis akan menginstal plugin Dart).

3. **Cek Instalasi dengan Flutter Doctor**  
   Jalankan perintah:
   flutter doctor
   Perintah ini akan memeriksa apakah semua komponen seperti Android SDK, emulator, dan plugin sudah terpasang dengan benar.

4. **Menjalankan Emulator atau Perangkat Fisik**  
Kamu bisa menggunakan emulator bawaan Android Studio atau langsung hubungkan ponsel melalui USB (aktifkan mode Developer dan USB Debugging).

5. **Uji Coba Pertama**  
Setelah semua siap, jalankan:
flutter create my_app
cd my_app
flutter run

Jika berhasil, akan muncul aplikasi Flutter default dengan tulisan “Flutter Demo Home Page”.

Dengan setup ini, kamu sudah siap membangun aplikasi Flutter pertamamu!
''',
        completed: false,
      ),
      Lesson(
        title: 'Membuat Aplikasi Pertama',
        subtitle: 'Langkah-langkah membuat aplikasi Flutter pertama Anda',
        content: '''
# Membuat Aplikasi Pertama

Sekarang saatnya membuat aplikasi Flutter pertamamu! Kita akan membuat aplikasi sederhana berupa *counter app*—aplikasi penghitung angka yang akan meningkat setiap kali tombol ditekan.

#### 1. Membuat Proyek Baru
Buka terminal dan jalankan:
flutter create my_first_app   
cd my_first_app

Folder proyek akan berisi struktur standar Flutter seperti:
- **lib/main.dart** (kode utama aplikasi)
- **pubspec.yaml** (file konfigurasi dependency)
- folder **android**, **ios**, dan **web** untuk platform terkait.

#### 2. Membuka Proyek di Editor
Buka folder `my_first_app` di Visual Studio Code atau Android Studio.  
File utama yang akan kita edit adalah **main.dart** di dalam folder `lib`.

#### 3. Struktur Dasar Flutter App
Flutter app biasanya dimulai dengan fungsi utama:
```dart
void main() {
  runApp(MyApp());
}
''',
        completed: false,
      ),
    ],
  ),
  Course(
    id: 'c2',
    title: 'UI/UX Design dengan Figma',
    categories: ['Design', 'User Experience', 'Figma', 'Creative'],
    price: 249000,
    owned: true,
    description:
        'Pelajari konsep desain antarmuka pengguna (UI) dan pengalaman pengguna (UX) secara mendalam. Termasuk praktik langsung menggunakan Figma dan prinsip desain interaktif.',
    imageUrls: [
      'https://miro.medium.com/v2/resize:fit:1200/1*YArv7xX2lVqNnp4FZdzpsQ.png',
      'https://cdn.dribbble.com/users/24029/screenshots/6133026/media/1c4e81c2836a4a9f9312d8a544c6eac7.png',
    ],
  ),
  Course(
    id: 'c3',
    title: 'Machine Learning Dasar',
    categories: ['AI', 'Machine Learning', 'Python', 'Data Science'],
    price: 189000,
    owned: false,
    description:
        'Kursus ini membahas dasar-dasar machine learning, mulai dari supervised dan unsupervised learning, hingga implementasi sederhana menggunakan Python dan scikit-learn.',
    imageUrls: [
      'https://miro.medium.com/v2/resize:fit:1200/1*qKovFDK6X2UURbX0dRjRZw.jpeg',
      'https://cdn.analyticsvidhya.com/wp-content/uploads/2019/05/machine-learning.jpg',
    ],
  ),
  Course(
    id: 'c4',
    title: 'Fullstack Web Development Bootcamp',
    categories: ['Web', 'JavaScript', 'Frontend', 'Backend'],
    price: 499000,
    owned: false,
    description:
        'Bangun website modern dari frontend hingga backend menggunakan React.js, Node.js, dan Express. Sertakan juga deployment ke server produksi.',
    imageUrls: [
      'https://cdn.hashnode.com/res/hashnode/image/upload/v1628879349593/xDgPN1efE.jpeg',
      'https://cdn.hashnode.com/res/hashnode/image/upload/v1628879511703/SS4wHDBkq.jpeg',
    ],
  ),
  Course(
    id: 'c5',
    title: 'Data Visualization',
    categories: ['Data', 'Visualization', 'Business Intelligence'],
    price: 99000,
    owned: false,
    description:
        'Pelajari cara mengubah data mentah menjadi visualisasi menarik menggunakan Microsoft Power BI. Cocok untuk analis data dan profesional bisnis.',
    imageUrls: [
      'https://cdn.educba.com/academy/wp-content/uploads/2019/07/Power-BI-Dashboard.jpg',
      'https://www.koenig-solutions.com/blog/wp-content/uploads/2023/02/Power-BI.jpg',
    ],
  ),
];

class Workshop {
  final String title;
  final String location;
  final double lat;
  final double lng;
  final String date;

  Workshop({
    required this.title,
    required this.location,
    required this.lat,
    required this.lng,
    required this.date,
  });
}

final List<Workshop> workshops = [
  Workshop(
    title: 'AI & Machine Learning Bootcamp',
    location: 'Medan, Sumatera Utara',
    lat: 3.5952,
    lng: 98.6722,
    date: '12 November 2025',
  ),
  Workshop(
    title: 'Flutter for Beginners',
    location: 'Yogyakarta, Jawa Tengah',
    lat: -7.7956,
    lng: 110.3695,
    date: '20 November 2025',
  ),
  Workshop(
    title: 'IoT Smart Devices',
    location: 'Balikpapan, Kalimantan Timur',
    lat: -1.2379,
    lng: 116.8525,
    date: '25 November 2025',
  ),
  Workshop(
    title: 'Cloud Computing Summit',
    location: 'London, UK',
    lat: 51.5074,
    lng: -0.1278,
    date: '5 Desember 2025',
  ),
];
