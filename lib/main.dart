import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/* ==================== CONSTANTS ==================== */

const String siteUrl = 'https://itarbiatbadani.ir';
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

/* ==================== STATIC CATEGORIES ==================== */

class CategoryItem {
  final int id;
  final String name;
  final String url;
  final IconData icon;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.url,
    required this.icon,
  });
}

const List<CategoryItem> staticCategories = [
  CategoryItem(
    id: 1,
    name: 'رشته تربیت بدنی و علوم ورزشی',
    url: '$siteUrl/category/physical-education-sport-sciences/',
    icon: Icons.sports_soccer,
  ),
  CategoryItem(
    id: 2,
    name: 'علوم ورزشی',
    url: '$siteUrl/category/sports-science/',
    icon: Icons.science_outlined,
  ),
  CategoryItem(
    id: 3,
    name: 'منابع آزمون‌های علوم ورزشی',
    url: '$siteUrl/category/sports-science-exam-resources/',
    icon: Icons.menu_book_outlined,
  ),
  CategoryItem(
    id: 4,
    name: 'تغذیه ورزشی',
    url: '$siteUrl/category/sports-nutrition/',
    icon: Icons.restaurant_outlined,
  ),
  CategoryItem(
    id: 5,
    name: 'اخبار و رویدادها',
    url: '$siteUrl/category/sports-news-and-events/',
    icon: Icons.newspaper_outlined,
  ),
  CategoryItem(
    id: 6,
    name: 'ورزش همگانی، سلامت و تندرستی',
    url: '$siteUrl/category/public-exercise-health-and-wellness/',
    icon: Icons.favorite_outline,
  ),
  CategoryItem(
    id: 7,
    name: 'پژوهش در تربیت بدنی',
    url: '$siteUrl/category/research-in-physical-education/',
    icon: Icons.search_outlined,
  ),
  CategoryItem(
    id: 8,
    name: 'تربیت بدنی و آموزش',
    url: '$siteUrl/category/physical-education-and-training/',
    icon: Icons.school_outlined,
  ),
  CategoryItem(
    id: 9,
    name: 'معرفی منابع و کتب مرجع',
    url: '$siteUrl/category/introduction-to-sources-and-reference-books/',
    icon: Icons.library_books_outlined,
  ),
  CategoryItem(
    id: 10,
    name: 'اصول ورزش و فعالیت بدنی',
    url: '$siteUrl/category/principles-of-exercise-and-physical-activity/',
    icon: Icons.fitness_center_outlined,
  ),
  CategoryItem(
    id: 11,
    name: 'آزمون‌های استخدامی',
    url: '$siteUrl/category/employment-tests/',
    icon: Icons.assignment_outlined,
  ),
  CategoryItem(
    id: 12,
    name: 'معرفی رشته‌های ورزشی',
    url: '$siteUrl/category/introduction-to-sports-disciplines/',
    icon: Icons.sports_handball_outlined,
  ),
  CategoryItem(
    id: 13,
    name: 'ورزش برای گروه‌ها و نیازهای ویژه',
    url: '$siteUrl/category/exercise-for-special-groups-and-needs/',
    icon: Icons.accessibility_new_outlined,
  ),
  CategoryItem(
    id: 14,
    name: 'فناوری و نوآوری در ورزش',
    url: '$siteUrl/category/technology-and-innovation-in-sports-sports-science/',
    icon: Icons.memory_outlined,
  ),
];

/* ==================== STATIC SUGGESTED POSTS ==================== */

class SuggestedPost {
  final String title;
  final String url;
  final IconData icon;

  const SuggestedPost({
    required this.title,
    required this.url,
    required this.icon,
  });
}

const List<SuggestedPost> suggestedPosts = [
  SuggestedPost(
    title: 'معرفی رشته تربیت بدنی و علوم ورزشی',
    url: '$siteUrl/introduction-to-the-field-of-physical-education-and-sports-sciences/',
    icon: Icons.info_outline,
  ),
  SuggestedPost(
    title: 'گرایش‌های کارشناسی ارشد',
    url: '$siteUrl/%da%af%d8%b1%d8%a7%db%8c%d8%b4%d9%87%d8%a7%db%8c-%da%a9%d8%a7%d8%b1%d8%b4%d9%86%d8%a7%d8%b3%db%8c-%d8%a7%d8%b1%d8%b4%d8%af-%d8%aa%d8%b1%d8%a8%db%8c%d8%aa-%d8%a8%d8%af%d9%86%db%8c-%d9%88/',
    icon: Icons.school_outlined,
  ),
  SuggestedPost(
    title: 'منابع آزمون دکتری علوم ورزشی',
    url: '$siteUrl/sports-science-phd-exam-resources/',
    icon: Icons.library_books_outlined,
  ),
  SuggestedPost(
    title: 'منابع کارشناسی ارشد',
    url: '$siteUrl/master-of-sports-science-resources/',
    icon: Icons.menu_book_outlined,
  ),
  SuggestedPost(
    title: 'منابع کنکور دکتری تربیت بدنی',
    url: '$siteUrl/manabe-konkur-doctori-tarbiat-badani/',
    icon: Icons.book_outlined,
  ),
  SuggestedPost(
    title: 'دانشگاه‌های برتر علوم ورزشی',
    url: '$siteUrl/physical-education-sports-science/',
    icon: Icons.account_balance,
  ),
  SuggestedPost(
    title: 'بازار کار تربیت بدنی',
    url: '$siteUrl/job-market-in-physical-education-and-sports-sciences/',
    icon: Icons.work_outline,
  ),
];

/* ==================== HELPERS ==================== */

Future<void> openUrl(String url) async {
  if (url.isEmpty || url == '#') return;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void openWebView(BuildContext context, String url, {String? title}) {
  if (url.isEmpty) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ArticleWebViewPage(url: url, title: title),
    ),
  );
}

/* ==================== APP ==================== */

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

/* ==================== MAIN PAGE ==================== */

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  static const int _shopIndex = 3;

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
          if (index == _shopIndex) {
            openUrl('$siteUrl/shop/');
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

/* ==================== HEADER ==================== */

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onSearch;

  const AppHeader({
    super.key,
    this.title = 'تربیت بدنی و علوم ورزشی',
    this.showBack = false,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          color: backgroundColor,
          border: Border(bottom: BorderSide(color: lineColor)),
        ),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_forward, color: textColor),
              ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: goldColor.withOpacity(0.4), width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(
                    logoNetwork,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.sports, color: goldColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onSearch,
              icon: const Icon(Icons.search, color: goldColor, size: 27),
            ),
          ],
        ),
      ),
    );
  }
}

/* ==================== HOME ==================== */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: goldColor,
      backgroundColor: panelColor,
      onRefresh: refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              onSearch: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 18, 14, 10),
              child: _HeroSection(),
            ),
          ),
          const SliverToBoxAdapter(child: ServicesSection()),

          /* ===== مطالب پیشنهادی (جایگزین جدیدترین نوشته‌ها) ===== */
          const SliverToBoxAdapter(
            child: SectionTitle(
              title: 'مطالب پیشنهادی',
              icon: Icons.article_outlined,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: suggestedPosts
                    .map((post) => _SuggestedPostCard(post: post))
                    .toList(),
              ),
            ),
          ),
          /* =================================================== */

          const SliverToBoxAdapter(
            child: SectionTitle(title: 'دسته‌بندی مطالب', icon: Icons.grid_view_rounded),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: staticCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  return _HomeCategoryCard(category: staticCategories[index]);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SocialSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}

/* ==================== SUGGESTED POST CARD ==================== */

class _SuggestedPostCard extends StatelessWidget {
  final SuggestedPost post;
  const _SuggestedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openWebView(context, post.url, title: post.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(post.icon, color: goldColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: mutedColor, size: 16),
          ],
        ),
      ),
    );
  }
}

/* ==================== HERO ==================== */

class _HeroSection extends StatelessWidget {
  const _HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xff0a3d62), Color(0xff102a3e)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: goldColor.withOpacity(0.5), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, color: goldColor, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تربیت بدنی و علوم ورزشی',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: goldColor, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'اپلیکیشن رسمی مرجع ورزش',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.6),
          ),
          const SizedBox(height: 10),
          const Text(
            'دسترسی سریع به جدیدترین اخبار، منابع علمی، طرح درس، پاورپوینت‌های آموزشی و مطالب تخصصی تربیت بدنی و علوم ورزشی — همه در یک اپلیکیشن ساده و سریع.',
            textAlign: TextAlign.right,
            style: TextStyle(color: Color(0xffc5d4df), fontSize: 13, height: 1.9),
          ),
        ],
      ),
    );
  }
}

/* ==================== SERVICES ==================== */

class ServiceItem {
  final String title;
  final IconData icon;
  final String url;
  const ServiceItem({required this.title, required this.icon, required this.url});
}

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  static const List<ServiceItem> services = [
    ServiceItem(title: 'معرفی رشته', icon: Icons.info_outline, url: '$siteUrl/introduction-to-the-field-of-physical-education-and-sports-sciences/'),
    ServiceItem(title: 'گرایش‌های ارشد', icon: Icons.school_outlined, url: '$siteUrl/%da%af%d8%b1%d8%a7%db%8c%d8%b4%d9%87%d8%a7%db%8c-%da%a9%d8%a7%d8%b1%d8%b4%d9%86%d8%a7%d8%b3%db%8c-%d8%a7%d8%b1%d8%b4%d8%af-%d8%aa%d8%b1%d8%a8%db%8c%d8%aa-%d8%a8%d8%af%d9%86%db%8c-%d9%88/'),
    ServiceItem(title: 'گرایش‌های دکتری', icon: Icons.account_balance_outlined, url: '$siteUrl/sports-science-phd-exam-resources/'),
    ServiceItem(title: 'منابع ارشد', icon: Icons.menu_book_outlined, url: '$siteUrl/master-of-sports-science-resources/'),
    ServiceItem(title: 'منابع دکتری', icon: Icons.library_books_outlined, url: '$siteUrl/manabe-konkur-doctori-tarbiat-badani/'),
    ServiceItem(title: 'دانشگاه‌های برتر', icon: Icons.account_balance, url: '$siteUrl/physical-education-sports-science/'),
    ServiceItem(title: 'بازار کار', icon: Icons.work_outline, url: '$siteUrl/job-market-in-physical-education-and-sports-sciences/'),
    ServiceItem(title: 'طرح درس', icon: Icons.assignment_outlined, url: '$siteUrl/product-category/%d8%b7%d8%b1%d8%ad-%d8%af%d8%b1%d8%b3-%d8%b1%d9%88%d8%b2%d8%a7%d9%86%d9%87-%d9%85%d8%a7%d9%87%d8%a7%d9%86%d9%87-%d8%b3%d8%a7%d9%84%d8%a7%d9%86%d9%87/'),
    ServiceItem(title: 'پاورپوینت', icon: Icons.slideshow_outlined, url: '$siteUrl/product-category/powerpoint/'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(title: 'خدمات ما', icon: Icons.apps),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = services[index];
              return GestureDetector(
                onTap: () => openUrl(item.url),
                child: Container(
                  width: 112,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: goldColor, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

/* ==================== SECTION TITLE ==================== */

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 25,
            decoration: BoxDecoration(color: goldColor, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 9),
          Icon(icon, color: goldColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==================== HOME CATEGORY CARD ==================== */

class _HomeCategoryCard extends StatelessWidget {
  final CategoryItem category;
  const _HomeCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openWebView(context, category.url, title: category.name),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: goldColor, size: 24),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  category.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ==================== SOCIAL ==================== */

class SocialSection extends StatelessWidget {
  const SocialSection({super.key});

  static const List<Map<String, dynamic>> socials = [
    {'title': 'تلگرام', 'icon': FontAwesomeIcons.telegram, 'url': 'https://t.me/itarbiatbadani'},
    {'title': 'اینستاگرام', 'icon': FontAwesomeIcons.instagram, 'url': 'https://instagram.com/itarbiatbadani'},
    {'title': 'بله', 'icon': FontAwesomeIcons.comment, 'url': 'https://ble.ir/itarbiatbadani'},
    {'title': 'فروشگاه', 'icon': FontAwesomeIcons.cartShopping, 'url': '$siteUrl/shop/'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(title: 'ارتباط با ما', icon: Icons.connect_without_contact),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: socials.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final item = socials[index];
              return GestureDetector(
                onTap: () => openUrl(item['url']),
                child: Container(
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(item['icon'], color: goldColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        item['title'],
                        style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ==================== CATEGORIES PAGE ==================== */

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: 'دسته‌بندی مطالب',
              onSearch: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: staticCategories
                    .map((c) => CategoryTile(category: c))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==================== CATEGORY TILE ==================== */

class CategoryTile extends StatelessWidget {
  final CategoryItem category;
  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openWebView(context, category.url, title: category.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: goldColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: mutedColor, size: 16),
          ],
        ),
      ),
    );
  }
}

/* ==================== NEWS PAGE ==================== */

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اخبار و رویدادها'),
        backgroundColor: backgroundColor,
      ),
      body: const Center(
        child: Text(
          'صفحه اخبار به زودی...',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}

/* ==================== ACCOUNT PAGE ==================== */

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب من'),
        backgroundColor: backgroundColor,
      ),
      body: const Center(
        child: Text(
          'صفحه حساب کاربری به زودی...',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}

/* ==================== SEARCH PAGE ==================== */

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جستجو'),
        backgroundColor: backgroundColor,
      ),
      body: const Center(
        child: Text(
          'صفحه جستجو به زودی...',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}

/* ==================== ARTICLE WEBVIEW PAGE ==================== */

class ArticleWebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const ArticleWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<ArticleWebViewPage> createState() => _ArticleWebViewPageState();
}

class _ArticleWebViewPageState extends State<ArticleWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() => isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'مشاهده مطلب'),
        backgroundColor: backgroundColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: goldColor),
            ),
        ],
      ),
    );
  }
}
