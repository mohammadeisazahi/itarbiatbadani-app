import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String siteUrl = 'https://itarbiatbadani.ir';

const String apiUrl = '$siteUrl/wp-json/wp/v2';

const String logoUrl =
    '$siteUrl/wp-content/uploads/2025/07/1000073463.png';

const Color backgroundColor = Color(0xff07131f);
const Color panelColor = Color(0xff0d2233);
const Color panelColor2 = Color(0xff102a3e);
const Color goldColor = Color(0xfffbc531);
const Color blueColor = Color(0xff1687d9);
const Color cyanColor = Color(0xff25b8e8);
const Color textColor = Color(0xfff4f7fa);
const Color mutedColor = Color(0xff9fb0bd);

Future<void> openUrl(String url) async {
  if (url.isEmpty || url == '#') return;

  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
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

/* =========================================================
   MAIN PAGE
   ========================================================= */

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
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xff081925),
        indicatorColor: goldColor.withOpacity(.18),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
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
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: goldColor),
            label: 'جستجو',
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   HEADER
   ========================================================= */

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
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: const BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: Color(0x1400ffffff),
            ),
          ),
        ),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                onPressed: () {
                  Navigator.maybePop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: textColor,
                ),
              ),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                logoUrl,
                width: 46,
                height: 46,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 46,
                    height: 46,
                    color: panelColor,
                    child: const Icon(
                      Icons.sports,
                      color: goldColor,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),

            IconButton(
              onPressed: onSearch,
              icon: const Icon(
                Icons.search,
                color: goldColor,
                size: 27,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
   HOME
   ========================================================= */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = WordPressApi.getPosts(perPage: 6);
  }

  Future<void> refresh() async {
    setState(() {
      postsFuture = WordPressApi.getPosts(perPage: 6);
    });

    await postsFuture;
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
                  MaterialPageRoute(
                    builder: (_) => const SearchPage(),
                  ),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
              child: _HeroSection(),
            ),
          ),

          SliverToBoxAdapter(
            child: ServicesSection(),
          ),

          SliverToBoxAdapter(
            child: SectionTitle(
              title: 'جدیدترین نوشته‌ها',
              icon: Icons.article_outlined,
            ),
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: goldColor,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorBox(
                    message:
                        'دریافت مطالب با مشکل مواجه شد.\nلطفاً اتصال اینترنت را بررسی کنید.',
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
                    children: posts
                        .map(
                          (post) => PostCard(post: post),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: SocialSection(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 25),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   HERO
   ========================================================= */

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff0a3d62),
            Color(0xff102a3e),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: goldColor.withOpacity(.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.sports_soccer,
                color: goldColor,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'تربیت بدنی و علوم ورزشی',
                style: TextStyle(
                  color: goldColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'مرجع تخصصی تربیت بدنی و علوم ورزشی',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'اخبار، آموزش، منابع علمی، طرح درس و مطالب تخصصی ورزش',
            style: TextStyle(
              color: Color(0xffc5d4df),
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   SERVICES
   ========================================================= */

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
  ServicesSection({super.key});

  final List<ServiceItem> services = const [
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
      url:
          '$siteUrl/manabe-konkur-doctori-tarbiat-badani/',
    ),
    ServiceItem(
      title: 'دانشگاه‌های برتر',
      icon: Icons.account_balance,
      url: '$siteUrl/physical-education-sports-science/',
    ),
    ServiceItem(
      title: 'بازار کار',
      icon: Icons.work_outline,
      url:
          '$siteUrl/job-market-in-physical-education-and-sports-sciences/',
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
        const SectionTitle(
          title: 'خدمات ما',
          icon: Icons.apps,
        ),
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
                    border: Border.all(
                      color: Colors.white.withOpacity(.06),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: goldColor,
                        size: 30,
                      ),
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

/* =========================================================
   SECTION TITLE
   ========================================================= */

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
          Icon(
            icon,
            color: goldColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   POST CARD
   ========================================================= */

class PostCard extends StatelessWidget {
  final dynamic post;

  const PostCard({
    super.key,
    required this.post,
  });

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
          border: Border.all(
            color: Colors.white.withOpacity(.06),
          ),
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
                        placeholder: (_, __) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: goldColor,
                            ),
                          );
                        },
                        errorWidget: (_, __, ___) {
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            color: mutedColor,
                            size: 35,
                          );
                        },
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

/* =========================================================
   SOCIAL
   ========================================================= */

class SocialSection extends StatelessWidget {
  SocialSection({super.key});

  final List<Map<String, dynamic>> socials = [
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
                    border: Border.all(
                      color: Colors.white.withOpacity(.06),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        color: goldColor,
                        size: 21,
                      ),
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

/* =========================================================
   CATEGORIES
   ========================================================= */

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
                  MaterialPageRoute(
                    builder: (_) => const SearchPage(),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: goldColor,
                      ),
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

                mainCategories.sort(
                  (a, b) {
                    final aIndex = allowedMainCategorySlugs
                        .toList()
                        .indexOf(a['slug']);
                    final bIndex = allowedMainCategorySlugs
                        .toList()
                        .indexOf(b['slug']);

                    return aIndex.compareTo(bIndex);
                  },
                );

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: mainCategories
                        .map(
                          (category) => CategoryTile(
                            category: category,
                          ),
                        )
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
  'sports-science-exam-resources',
  'sports-nutrition',
  'sports-news-and-events',
  'public-exercise-health-and-wellness',
  'research-in-physical-education',
  'physical-education-and-training',
  'introduction-to-sources-and-reference-books',
  'principles-of-exercise-and-physical-activity',
  'employment-tests',
  'introduction-to-sports-disciplines',
  'exercise-for-special-groups-and-needs',
  'technology-and-innovation-in-sports',
};

class CategoryTile extends StatelessWidget {
  final dynamic category;

  const CategoryTile({
    super.key,
    required this.category,
  });

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
          border: Border.all(
            color: Colors.white.withOpacity(.06),
          ),
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
              child: const Icon(
                Icons.folder_outlined,
                color: goldColor,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
   SUB CATEGORIES
   ========================================================= */

class SubCategoriesPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoriesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoriesPage> createState() =>
      _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future =
        WordPressApi.getSubCategories(widget.categoryId);
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
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: goldColor,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const ErrorBox(
                    message: 'دریافت زیر دسته‌ها انجام نشد.',
                  );
                }

                final subCategories =
                    snapshot.data ?? [];

                if (subCategories.isEmpty) {
                  return CategoryPostsPage(
                    categoryId: widget.categoryId,
                    categoryName: widget.categoryName,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: subCategories
                        .map(
                          (category) => CategoryTile(
                            category: category,
                          ),
                        )
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

/* =========================================================
   CATEGORY POSTS
   ========================================================= */

class CategoryPostsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPostsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsPage> createState() =>
      _CategoryPostsPageState();
}

class _CategoryPostsPageState
    extends State<CategoryPostsPage> {
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();

    future = WordPressApi.getPosts(
      perPage: 20,
      category: widget.categoryId,
    );
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
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: goldColor,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const ErrorBox(
                    message: 'دریافت مطالب انجام نشد.',
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(
                      child: Text(
                        'در این دسته مطلبی پیدا نشد.',
                        style: TextStyle(
                          color: mutedColor,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: posts
                        .map(
                          (post) => PostCard(post: post),
                        )
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

/* =========================================================
   SEARCH
   ========================================================= */

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller =
      TextEditingController();

  List<dynamic> results = [];
  bool loading = false;
  bool searched = false;

  Future<void> search() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      searched = true;
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
    } catch (_) {
      if (!mounted) return;

      setState(() {
        results = [];
        loading = false;
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
              padding: const EdgeInsets.fromLTRB(
                14,
                18,
                14,
                10,
              ),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => search(),
                style: const TextStyle(
                  color: textColor,
                ),
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
                    icon: const Icon(
                      Icons.search,
                      color: goldColor,
                    ),
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
                  child: CircularProgressIndicator(
                    color: goldColor,
                  ),
                ),
              ),
            )
          else if (searched && results.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(35),
                child: Center(
                  child: Text(
                    'نتیجه‌ای پیدا نشد.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return PostCard(
                      post: results[index],
                    );
                  },
                  childCount: results.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* =========================================================
   ERROR BOX
   ========================================================= */

class ErrorBox extends StatelessWidget {
  final String message;

  const ErrorBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withOpacity(.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: mutedColor,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   WORDPRESS API
   ========================================================= */

class WordPressApi {
  static Future<List<dynamic>> getPosts({
    int page = 1,
    int perPage = 6,
    String? search,
    int? category,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'orderby': 'date',
      'order': 'desc',
      '_embed': 'true',
    };

    if (search != null &&
        search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (category != null) {
      params['categories'] = category.toString();
    }

    final uri = Uri.parse(
      '$apiUrl/posts',
    ).replace(
      queryParameters: params,
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      }

      throw Exception('پاسخ نامعتبر از وردپرس');
    }

    throw Exception(
      'خطا در دریافت مطالب: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> getCategories() async {
    final uri = Uri.parse(
      '$apiUrl/categories',
    ).replace(
      queryParameters: {
        'per_page': '100',
        'hide_empty': 'true',
        'orderby': 'name',
        'order': 'asc',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      }

      throw Exception('پاسخ نامعتبر از وردپرس');
    }

    throw Exception(
      'خطا در دریافت دسته‌ها: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> getSubCategories(
    int parentId,
  ) async {
    final uri = Uri.parse(
      '$apiUrl/categories',
    ).replace(
      queryParameters: {
        'per_page': '100',
        'hide_empty': 'true',
        'parent': parentId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      }

      throw Exception('پاسخ نامعتبر از وردپرس');
    }

    throw Exception(
      'خطا در دریافت زیر دسته‌ها: ${response.statusCode}',
    );
  }
}
