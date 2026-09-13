import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/* ==================== CONSTANTS ==================== */

const String siteUrl = 'https://itarbiatbadani.ir';
const String apiUrl = '$siteUrl/wp-json/wp/v2';

/// لوگوی محلی (داخل assets) — برای نمایش در هدر
const String logoAsset = 'assets/images/logo.png';

/// لوگوی آنلاین — به‌عنوان fallback
const String logoNetwork =
    '$siteUrl/wp-content/uploads/2025/07/1000073463.png';

const Color backgroundColor = Color(0xff07131f);
const Color panelColor = Color(0xff0d2233);
const Color panelColor2 = Color(0xff102a3e);
const Color goldColor = Color(0xfffbc531);
const Color blueColor = Color(0xff1687d9);
const Color cyanColor = Color(0xff25b8e8);
const Color textColor = Color(0xfff4f7fa);
const Color mutedColor = Color(0xff9fb0bd);

const Duration _httpTimeout = Duration(seconds: 25);

/* ==================== HELPERS ==================== */

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
    final media = post['_embedded']['wp:featuredmedia'][0];
    return media['source_url'] ?? '';
  } catch (_) {
    return '';
  }
}

/* ==================== APP ==================== */

void main() {
  runApp(const ItarbiatbadaniApp());
}

class ItarbiatbadaniApp extends StatelessWidget {
  const ItarbiatbadaniApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: goldColor,
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
        ),
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
        backgroundColor: const Color(0xff081925),
        indicatorColor: goldColor.withOpacity(.18),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == _shopIndex) {
            openUrl('$siteUrl/shop/');
            return;
          }
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: goldColor),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: goldColor),
            label: 'دسته‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article, color: goldColor),
            label: 'اخبار',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: goldColor),
            label: 'فروشگاه',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: goldColor),
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
          border: Border(bottom: BorderSide(color: Color(0x1400ffffff))),
        ),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_forward, color: textColor),
              ),

            /* 🏋️ لوگو */
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: goldColor.withOpacity(.4),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(
                    logoNetwork,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.sports,
                      color: goldColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            /* 📝 نام اصلی */
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(),

            /* 🔍 دکمه جستجو */
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
  late Future<List<dynamic>> postsFuture;
  late Future<List<dynamic>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = WordPressApi.getPosts(perPage: 6);
    categoriesFuture = WordPressApi.getCategories();
  }

  Future<void> refresh() async {
    final posts = WordPressApi.getPosts(perPage: 6);
    final cats = WordPressApi.getCategories();

    setState(() {
      postsFuture = posts;
      categoriesFuture = cats;
    });

    try {
      await Future.wait([posts, cats]);
    } catch (_) {}
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

          const SliverToBoxAdapter(
            child: SectionTitle(
              title: 'جدیدترین نوشته‌ها',
              icon: Icons.article_outlined,
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: CircularProgressIndicator(color: goldColor),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorBox(
                    message:
                        'دریافت مطالب با مشکل مواجه شد.\nلطفاً اتصال اینترنت را بررسی کنید.',
                    onRetry: refresh,
                  );
                }

                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'مطلبی پیدا نشد.',
                        style: TextStyle(color: mutedColor),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children:
                        posts.map((post) => PostCard(post: post)).toList(),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(
            child: SectionTitle(
              title: 'دسته‌بندی مطالب',
              icon: Icons.grid_view_rounded,
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: CircularProgressIndicator(color: goldColor),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const ErrorBox(
                    message: 'دریافت دسته‌بندی‌ها انجام نشد.',
                  );
                }

                final categories = snapshot.data ?? [];
                final mainCategories = categories
                    .where(
                      (c) =>
                          c['parent'] == 0 &&
                          allowedMainCategorySlugs.contains(c['slug']),
                    )
                    .toList();

                final ordered = allowedMainCategorySlugs.toList();
                mainCategories.sort((a, b) {
                  final ai = ordered.indexOf(a['slug']);
                  final bi = ordered.indexOf(b['slug']);
                  return ai.compareTo(bi);
                });

                if (mainCategories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'دسته‌ای پیدا نشد.',
                        style: TextStyle(color: mutedColor),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mainCategories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      return _HomeCategoryCard(
                        category: mainCategories[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SocialSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}

/* ==================== HERO ==================== */

class _HeroSection extends StatelessWidget {
  const _HeroSection();

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
        border: Border.all(color: goldColor.withOpacity(.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              /* لوگوی داخل Hero */
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: goldColor.withOpacity(.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.sports_soccer,
                      color: goldColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تربیت بدنی و علوم ورزشی',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: goldColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'اپلیکیشن رسمی مرجع ورزش',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'دسترسی سریع به جدیدترین اخبار، منابع علمی، طرح درس، '
            'پاورپوینت‌های آموزشی و مطالب تخصصی تربیت بدنی و علوم ورزشی — '
            'همه در یک اپلیکیشن ساده و سریع.',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xffc5d4df),
              fontSize: 13,
              height: 1.9,
            ),
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

  const ServiceItem({
    required this.title,
    required this.icon,
    required this.url,
  });
}

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  static const List<ServiceItem> services = [
    ServiceItem(
      title: 'معرفی رشته',
      icon: Icons.info_outline,
      url:
          '$siteUrl/introduction-to-the-field-of-physical-education-and-sports-sciences/',
    ),
    ServiceItem(
      title: 'گرایش‌های ارشد',
      icon: Icons.school_outlined,
      url:
          '$siteUrl/%da%af%d8%b1%d8%a7%db%8c%d8%b4%d9%87%d8%a7%db%8c-%da%a9%d8%a7%d8%b1%d8%b4%d9%86%d8%a7%d8%b3%db%8c-%d8%a7%d8%b1%d8%b4%d8%af-%d8%aa%d8%b1%d8%a8%db%8c%d8%aa-%d8%a8%d8%af%d9%86%db%8c-%d9%88/',
    ),
    ServiceItem(
      title: 'گرایش‌های دکتری',
      icon: Icons.account_balance_outlined,
      url: '$siteUrl/sports-science-phd-exam-resources/',
    ),
    ServiceItem(
      title: 'منابع ارشد',
      icon: Icons.menu_book_outlined,
      url: '$siteUrl/master-of-sports-science-resources/',
    ),
    ServiceItem(
      title: 'منابع دکتری',
      icon: Icons.library_books_outlined,
      url: '$siteUrl/manabe-konkur-doctori-tarbiat-badani/',
    ),
    ServiceItem(
      title: 'دانشگاه‌های برتر',
      icon: Icons.account_balance,
      url: '$siteUrl/physical-education-sports-science/',
    ),
    ServiceItem(
      title: 'بازار کار',
      icon: Icons.work_outline,
      url: '$siteUrl/job-market-in-physical-education-and-sports-sciences/',
    ),
    ServiceItem(
      title: 'طرح درس',
      icon: Icons.assignment_outlined,
      url:
          '$siteUrl/product-category/%d8%b7%d8%b1%d8%ad-%d8%af%d8%b1%d8%b3-%d8%b1%d9%88%d8%b2%d8%a7%d9%86%d9%87-%d9%85%d8%a7%d9%87%d8%a7%d9%86%d9%87-%d8%b3%d8%a7%d9%84%d8%a7%d9%86%d9%87/',
    ),
    ServiceItem(
      title: 'پاورپوینت',
      icon: Icons.slideshow_outlined,
      url: '$siteUrl/product-category/powerpoint/',
    ),
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
                    border: Border.all(color: Colors.white.withOpacity(.06)),
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
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
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

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 25,
            decoration: BoxDecoration(
              color: goldColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 9),
          Icon(icon, color: goldColor, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==================== POST CARD ==================== */

class PostCard extends StatelessWidget {
  final dynamic post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final image = postImage(post);
    final title = postTitle(post);

    return GestureDetector(
      onTap: () => openUrl(postLink(post)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: SizedBox(
                width: 125,
                height: 110,
                child: image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: goldColor,
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: mutedColor,
                          size: 35,
                        ),
                      )
                    : const Icon(
                        Icons.article_outlined,
                        color: goldColor,
                        size: 40,
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Text(
                  title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ==================== HOME CATEGORY CARD ==================== */

class _HomeCategoryCard extends StatelessWidget {
  final dynamic category;

  const _HomeCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final name = cleanHtml(category['name'] ?? '');
    final id = category['id'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoriesPage(
              categoryId: id,
              categoryName: name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_outlined,
                color: goldColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
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
    {
      'title': 'تلگرام',
      'icon': Icons.send,
      'url': 'https://t.me/itarbiatbadani',
    },
    {
      'title': 'اینستاگرام',
      'icon': Icons.camera_alt_outlined,
      'url': 'https://instagram.com/itarbiatbadani',
    },
    {
      'title': 'بله',
      'icon': Icons.chat_outlined,
      'url': 'https://ble.ir/itarbiatbadani',
    },
    {
      'title': 'فروشگاه',
      'icon': Icons.shopping_cart_outlined,
      'url': '$siteUrl/shop/',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(
          title: 'ارتباط با ما',
          icon: Icons.connect_without_contact,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: socials.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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
                    border:
                        Border.all(color: Colors.white.withOpacity(.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], color: goldColor, size: 21),
                      const SizedBox(width: 8),
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
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

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<dynamic>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = WordPressApi.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
            child: FutureBuilder<List<dynamic>>(
              future: categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: goldColor),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const ErrorBox(
                    message: 'دریافت دسته‌بندی‌ها انجام نشد.',
                  );
                }

                final categories = snapshot.data ?? [];
                final mainCategories = categories
                    .where(
                      (category) =>
                          category['parent'] == 0 &&
                          allowedMainCategorySlugs
                              .contains(category['slug']),
                    )
                    .toList();

                final ordered = allowedMainCategorySlugs.toList();
                mainCategories.sort((a, b) {
                  final aIndex = ordered.indexOf(a['slug']);
                  final bIndex = ordered.indexOf(b['slug']);
                  return aIndex.compareTo(bIndex);
                });

                if (mainCategories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: Text(
                        'دسته‌ای یافت نشد.',
                        style: TextStyle(color: mutedColor),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: mainCategories
                        .map((c) => CategoryTile(category: c))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const Set<String> allowedMainCategorySlugs = {
  'physical-education-sport-sciences',
  'sports-science',
  'introduction-to-sports-disciplines',
  'sports-science-exam-resources',
  'introduction-to-sources-and-reference-books',
  'physical-education-and-training',
  'principles-of-exercise-and-physical-activity',
  'sports-nutrition',
  'public-exercise-health-and-wellness',
  'exercise-for-special-groups-and-needs',
  'technology-and-innovation-in-sports',
  'research-in-physical-education',
  'sports-news-and-events',
  'employment-tests',
};

/* ==================== CATEGORY TILE ==================== */

class CategoryTile extends StatelessWidget {
  final dynamic category;

  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final name = cleanHtml(category['name'] ?? '');
    final id = category['id'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoriesPage(
              categoryId: id,
              categoryName: name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_outlined, color: goldColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: mutedColor),
          ],
        ),
      ),
    );
  }
}

/* ==================== SUB CATEGORIES ==================== */

class SubCategoriesPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoriesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoriesPage> createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = WordPressApi.getSubCategories(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: widget.categoryName,
              showBack: true,
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: goldColor),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const ErrorBox(
                    message: 'دریافت زیر دسته‌ها انجام نشد.',
                  );
                }

                final subCategories = snapshot.data ?? [];

                if (subCategories.isEmpty) {
                  return CategoryPostsList(categoryId: widget.categoryId);
                }

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: subCategories
                        .map((c) => CategoryTile(category: c))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ==================== CATEGORY POSTS LIST ==================== */

class CategoryPostsList extends StatefulWidget {
  final int categoryId;

  const CategoryPostsList({super.key, required this.categoryId});

  @override
  State<CategoryPostsList> createState() => _CategoryPostsListState();
}

class _CategoryPostsListState extends State<CategoryPostsList> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = WordPressApi.getPosts(
      perPage: 20,
      category: widget.categoryId,
    );
  }

  Future<void> _refresh() async {
    final future = WordPressApi.getPosts(
      perPage: 20,
      category: widget.categoryId,
    );
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: goldColor)),
          );
        }
        if (snapshot.hasError) {
          return ErrorBox(
            message: 'دریافت مطالب انجام نشد.',
            onRetry: _refresh,
          );
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(35),
            child: Center(
              child: Text(
                'در این دسته مطلبی پیدا نشد.',
                style: TextStyle(color: mutedColor),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: posts.map((post) => PostCard(post: post)).toList(),
          ),
        );
      },
    );
  }
}

/* ==================== NEWS PAGE ==================== */

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadNews();
  }

  Future<List<dynamic>> _loadNews() async {
    final categories = await WordPressApi.getCategories();
    dynamic newsCategory;
    try {
      newsCategory = categories.firstWhere(
        (c) => c['slug'] == 'sports-news-and-events',
      );
    } catch (_) {
      newsCategory = null;
    }

    if (newsCategory == null) {
      return WordPressApi.getPosts(perPage: 20);
    }

    return WordPressApi.getPosts(
      perPage: 20,
      category: newsCategory['id'],
    );
  }

  Future<void> _refresh() async {
    final future = _loadNews();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: goldColor,
        backgroundColor: panelColor,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'اخبار ورزشی',
                onSearch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchPage(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(color: goldColor),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return ErrorBox(
                      message: 'دریافت اخبار انجام نشد.',
                      onRetry: _refresh,
                    );
                  }

                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(35),
                      child: Center(
                        child: Text(
                          'خبری برای نمایش وجود ندارد.',
                          style: TextStyle(color: mutedColor),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: posts
                          .map((post) => PostCard(post: post))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
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
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AppHeader(title: 'حساب من'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: goldColor.withOpacity(.5),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        logoAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 55,
                          color: goldColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'کاربر مهمان',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'برای دسترسی به امکانات بیشتر وارد شوید',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _AccountTile(
                    icon: Icons.login,
                    title: 'ورود به حساب',
                    onTap: () => openUrl('$siteUrl/wp-login.php'),
                  ),
                  _AccountTile(
                    icon: Icons.person_add_alt,
                    title: 'ثبت‌نام',
                    onTap: () =>
                        openUrl('$siteUrl/wp-login.php?action=register'),
                  ),
                  _AccountTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'سفارش‌های من',
                    onTap: () => openUrl('$siteUrl/my-account/orders/'),
                  ),
                  _AccountTile(
                    icon: Icons.favorite_border,
                    title: 'علاقه‌مندی‌ها',
                    onTap: () => openUrl('$siteUrl/my-account/'),
                  ),
                  _AccountTile(
                    icon: Icons.info_outline,
                    title: 'درباره ما',
                    onTap: () => openUrl('$siteUrl/about-us/'),
                  ),
                  _AccountTile(
                    icon: Icons.support_agent,
                    title: 'تماس با ما',
                    onTap: () => openUrl('$siteUrl/contact/'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: goldColor, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: mutedColor),
          ],
        ),
      ),
    );
  }
}

/* ==================== SEARCH PAGE ==================== */

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();

  List<dynamic> results = [];
  bool loading = false;
  bool searched = false;
  String? _error;

  Future<void> search() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      searched = true;
      _error = null;
    });

    try {
      final data = await WordPressApi.getPosts(
        search: text,
        perPage: 20,
      );
      if (!mounted) return;
      setState(() {
        results = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        results = [];
        loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: 'جستجوی مطالب',
              showBack: Navigator.canPop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => search(),
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'عنوان یا موضوع مورد نظر را جستجو کنید...',
                  hintStyle: const TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: panelColor,
                  prefixIcon: IconButton(
                    onPressed: search,
                    icon: const Icon(Icons.search, color: goldColor),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: goldColor),
                ),
              ),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: ErrorBox(
                message: 'جستجو با خطا مواجه شد.\n$_error',
                onRetry: search,
              ),
            )
          else if (searched && results.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(35),
                child: Center(
                  child: Text(
                    'نتیجه‌ای پیدا نشد.',
                    style: TextStyle(color: mutedColor, fontSize: 15),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostCard(post: results[index]),
                  childCount: results.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ==================== ERROR BOX ==================== */

class ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorBox({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: mutedColor, height: 1.7),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: goldColor),
                label: const Text(
                  'تلاش دوباره',
                  style: TextStyle(color: goldColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ==================== WORDPRESS API ==================== */

class WordPressApi {
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  static Future<List<dynamic>> getPosts({
    int page = 1,
    int perPage = 6,
    String? search,
    int? category,
    bool embed = true,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'orderby': 'date',
      'order': 'desc',
    };

    if (embed) params['_embed'] = 'true';
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (category != null) {
      params['categories'] = category.toString();
    }

    return _getList('$apiUrl/posts', params, 'مطالب');
  }

  static Future<List<dynamic>> getCategories() async {
    return _getList(
      '$apiUrl/categories',
      {
        'per_page': '100',
        'orderby': 'name',
        'order': 'asc',
      },
      'دسته‌ها',
    );
  }

  static Future<List<dynamic>> getSubCategories(int parentId) async {
    return _getList(
      '$apiUrl/categories',
      {
        'per_page': '100',
        'parent': parentId.toString(),
      },
      'زیر دسته‌ها',
    );
  }

  static Future<List<dynamic>> _getList(
    String endpoint,
    Map<String, String> params,
    String label,
  ) async {
    final uri = Uri.parse(endpoint).replace(queryParameters: params);

    debugPrint('🌐 GET: $uri');

    late final http.Response response;
    try {
      response = await http
          .get(uri, headers: _headers)
          .timeout(_httpTimeout);
    } on TimeoutException {
      debugPrint('❌ TIMEOUT: $uri');
      throw Exception('زمان پاسخ‌دهی سرور به پایان رسید.');
    } catch (e) {
      debugPrint('❌ CONNECTION ERROR: $e');
      throw Exception('اتصال به سرور برقرار نشد.');
    }

    debugPrint('📥 ${response.statusCode} | ${response.body.length} bytes');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      throw Exception('پاسخ نامعتبر از وردپرس');
    }

    if (response.statusCode == 400) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map &&
            decoded['code'] == 'rest_post_invalid_page_number') {
          return <dynamic>[];
        }
      } catch (_) {}
    }

    debugPrint('❌ ERROR BODY: ${response.body}');

    throw Exception(
      'خطا در دریافت $label (کد ${response.statusCode})',
    );
  }
}
