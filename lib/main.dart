import 'package:flutter/material.dart';

const String siteUrl = 'https://itarbiatbadani.ir';
const String apiUrl = '$siteUrl/wp-json/wp/v2';
const String logoAsset = 'assets/images/logo.png';
const String logoNetwork =
    '$siteUrl/wp-content/uploads/2025/07/1000073463.png';

const Color backgroundColor = Color(0xff07131f);
const Color panelColor = Color(0xff0d2233);
const Color panelColor2 = Color(0xff102a3e);
const Color goldColor = Color(0xfffbc531);
const Color textColor = Color(0xfff4f7fa);
const Color mutedColor = Color(0xff9fb0bd);
const Color lineColor = Color(0x17ffffff);

class CategoryItem {
  final int id;
  final String name;
  final String slug;
  final IconData icon;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });
}

const List<CategoryItem> staticCategories = [
  CategoryItem(id: 1, name: 'رشته تربیت بدنی و علوم ورزشی', slug: 'physical-education-sport-sciences', icon: Icons.sports_soccer),
  CategoryItem(id: 2, name: 'علوم ورزشی', slug: 'sports-science', icon: Icons.science_outlined),
  CategoryItem(id: 3, name: 'منابع آزمون‌های علوم ورزشی', slug: 'sports-science-exam-resources', icon: Icons.menu_book_outlined),
  CategoryItem(id: 4, name: 'تغذیه ورزشی', slug: 'sports-nutrition', icon: Icons.restaurant_outlined),
  CategoryItem(id: 5, name: 'اخبار و رویدادها', slug: 'sports-news-and-events', icon: Icons.newspaper_outlined),
  CategoryItem(id: 6, name: 'ورزش همگانی، سلامت و تندرستی', slug: 'public-exercise-health-and-wellness', icon: Icons.favorite_outline),
  CategoryItem(id: 7, name: 'پژوهش در تربیت بدنی', slug: 'research-in-physical-education', icon: Icons.search_outlined),
  CategoryItem(id: 8, name: 'تربیت بدنی و آموزش', slug: 'physical-education-and-training', icon: Icons.school_outlined),
  CategoryItem(id: 9, name: 'معرفی منابع و کتب مرجع', slug: 'introduction-to-sources-and-reference-books', icon: Icons.library_books_outlined),
  CategoryItem(id: 10, name: 'اصول ورزش و فعالیت بدنی', slug: 'principles-of-exercise-and-physical-activity', icon: Icons.fitness_center_outlined),
  CategoryItem(id: 11, name: 'آزمون‌های استخدامی', slug: 'employment-tests', icon: Icons.assignment_outlined),
  CategoryItem(id: 12, name: 'معرفی رشته‌های ورزشی', slug: 'introduction-to-sports-disciplines', icon: Icons.sports_handball_outlined),
  CategoryItem(id: 13, name: 'ورزش برای گروه‌ها و نیازهای ویژه', slug: 'exercise-for-special-groups-and-needs', icon: Icons.accessibility_new_outlined),
  CategoryItem(id: 14, name: 'فناوری و نوآوری در ورزش', slug: 'technology-and-innovation-in-sports-sports-science', icon: Icons.memory_outlined),
];
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String url) async {
  if (url.isEmpty || url == '#') return;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String cleanHtml(String value) {
  return value
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#8217;', '’')
      .replaceAll('&#8216;', '‘')
      .replaceAll('&#8220;', '“')
      .replaceAll('&#8221;', '”')
      .replaceAll('&#8230;', '…')
      .trim();
}

String postTitle(dynamic post) {
  try {
    return cleanHtml(post['title']['rendered'] ?? 'بدون عنوان');
  } catch (_) {
    return 'بدون عنوان';
  }
}

String postLink(dynamic post) {
  try {
    return post['link'] ?? '';
  } catch (_) {
    return '';
  }
}

String postImage(dynamic post) {
  try {
    final media = post['_embedded']?['wp:featuredmedia'];
    if (media is List && media.isNotEmpty) {
      return media[0]['source_url'] ?? '';
    }
  } catch (_) {}
  return '';
}

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso).toLocal();
    const months = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
    ];
    final j = _gregorianToJalali(dt.year, dt.month, dt.day);
    return '${j[2]} ${months[j[1] - 1]} ${j[0]}';
  } catch (_) {
    return '';
  }
}

List<int> _gregorianToJalali(int gy, int gm, int gd) {
  const gdm = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  const jdm = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];

  var gy2 = (gm > 2) ? (gy + 1) : gy;
  var days = 355666 + (365 * gy) + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) + gd;

  for (var i = 0; i < gm - 1; i++) {
    days += gdm[i];
  }

  var jy = -1595 + (33 * (days ~/ 12053));
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;

  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }

  var jm = 0;
  var jd = days + 1;
  for (var i = 0; i < 12; i++) {
    if (jd <= jdm[i]) {
      jm = i + 1;
      break;
    }
    jd -= jdm[i];
  }

  return [jy, jm, jd];
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class WordPressApi {
  static Future<List<dynamic>> getLatestPosts({int perPage = 6}) async {
    final response = await http.get(
      Uri.parse('$apiUrl/posts?per_page=$perPage&_embed'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('خطا در دریافت مطالب: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getPostsByCategory(int categoryId,
      {int perPage = 20}) async {
    final response = await http.get(
      Uri.parse('$apiUrl/posts?categories=$categoryId&per_page=$perPage&_embed'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('خطا در دریافت مطالب دسته: ${response.statusCode}');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'pages/home_page.dart';
import 'pages/categories_page.dart';
import 'pages/news_page.dart';
import 'pages/account_page.dart';

void main() {
  runApp(const ItarbiatbadaniApp());
}

class ItarbiatbadaniApp extends StatelessWidget {
  const ItarbiatbadaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: goldColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تربیت بدنی و علوم ورزشی',
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: base.copyWith(
        textTheme: GoogleFonts.vazirmatnTextTheme(base.textTheme),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    CategoriesPage(),
    NewsPage(),
    SizedBox.shrink(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: const Color(0xff081925),
        indicatorColor: goldColor.withOpacity(0.18),
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == 3) {
            // فروشگاه - باز کردن لینک
            return;
          }
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24, color: mutedColor),
            selectedIcon: Icon(Icons.home, size: 24, color: goldColor),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined, size: 24, color: mutedColor),
            selectedIcon: Icon(Icons.category, size: 24, color: goldColor),
            label: 'دسته‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined, size: 24, color: mutedColor),
            selectedIcon: Icon(Icons.newspaper, size: 24, color: goldColor),
            label: 'اخبار',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, size: 24, color: mutedColor),
            selectedIcon: Icon(Icons.shopping_cart, size: 24, color: goldColor),
            label: 'فروشگاه',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 24, color: mutedColor),
            selectedIcon: Icon(Icons.person, size: 24, color: goldColor),
            label: 'حساب من',
          ),
        ],
      ),
    );
  }
}
