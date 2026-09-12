import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ItarbiatBadaniApp());
}

class ItarbiatBadaniApp extends StatelessWidget {
  const ItarbiatBadaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تربیت بدنی و علوم ورزشی',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff07131f),
        fontFamily: 'Vazir',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfffbc531),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    CategoriesScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xff0d2233),
        indicatorColor: const Color(0xfffbc531),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: Color(0xff07131f),
            ),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(
              Icons.category,
              color: Color(0xff07131f),
            ),
            label: 'دسته‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(
              Icons.search,
              color: Color(0xff07131f),
            ),
            label: 'جستجو',
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';

import 'package:http/http.dart' as http;

class WordPressApi {
  static const String siteUrl = 'https://itarbiatbadani.ir';

  static const String apiUrl =
      '$siteUrl/wp-json/wp/v2';

  static Future<List<dynamic>> getPosts({
    int page = 1,
    int perPage = 6,
    String? search,
    int? category,
  }) async {
    final Map<String, String> params = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      'orderby': 'date',
      'order': 'desc',
      '_embed': 'true',
    };

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (category != null) {
      params['categories'] = category.toString();
    }

    final uri = Uri.parse(
      '$apiUrl/posts',
    ).replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
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

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'خطا در دریافت دسته‌ها',
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

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'خطا در دریافت زیر دسته‌ها',
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatelessWidget {
  final dynamic post;

  const PostCard({
    super.key,
    required this.post,
  });

  String getTitle() {
    return post['title']?['rendered'] ?? 'بدون عنوان';
  }

  String getLink() {
    return post['link'] ?? '';
  }

  String getImage() {
    try {
      final media =
          post['_embedded']['wp:featuredmedia'][0];

      return media['source_url'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> openPost() async {
    final link = getLink();

    if (link.isEmpty) return;

    final uri = Uri.parse(link);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage();

    return InkWell(
      onTap: openPost,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xff0d2233),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(.07),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: SizedBox(
                width: 120,
                height: 105,
                child: image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, error) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.article,
                        size: 40,
                        color: Color(0xfffbc531),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  getTitle(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.7,
                    fontSize: 14,
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
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

class ServiceCards extends StatelessWidget {
  const ServiceCards({super.key});

  static const services = [
    ServiceItem(
      title: 'معرفی رشته',
      icon: FontAwesomeIcons.circleInfo,
      url:
          'https://itarbiatbadani.ir/introduction-to-the-field-of-physical-education-and-sports-sciences/',
    ),
    ServiceItem(
      title: 'گرایش‌های ارشد',
      icon: FontAwesomeIcons.layerGroup,
      url:
          'https://itarbiatbadani.ir/%da%af%d8%b1%d8%a7%db%8c%d8%b4%d9%87%d8%a7%db%8c-%da%a9%d8%a7%d8%b1%d8%b4%d9%86%d8%a7%d8%b3%db%8c-%d8%a7%d8%b1%d8%b4%d8%af-%d8%aa%d8%b1%d8%a8%db%8c%d8%aa-%d8%a8%d8%af%d9%86%db%8c-%d9%88/',
    ),
    ServiceItem(
      title: 'گرایش‌های دکتری',
      icon: FontAwesomeIcons.graduationCap,
      url:
          'https://itarbiatbadani.ir/sports-science-phd-exam-resources/',
    ),
    ServiceItem(
      title: 'منابع ارشد',
      icon: FontAwesomeIcons.book,
      url:
          'https://itarbiatbadani.ir/master-of-sports-science-resources/',
    ),
    ServiceItem(
      title: 'منابع دکتری',
      icon: FontAwesomeIcons.bookOpen,
      url:
          'https://itarbiatbadani.ir/manabe-konkur-doctori-tarbiat-badani/',
    ),
    ServiceItem(
      title: 'منابع استخدامی',
      icon: FontAwesomeIcons.clipboardList,
      url: '',
    ),
    ServiceItem(
      title: 'دانشگاه‌های برتر',
      icon: FontAwesomeIcons.university,
      url:
          'https://itarbiatbadani.ir/physical-education-sports-science/',
    ),
    ServiceItem(
      title: 'بازار کار',
      icon: FontAwesomeIcons.briefcase,
      url:
          'https://itarbiatbadani.ir/job-market-in-physical-education-and-sports-sciences/',
    ),
    ServiceItem(
      title: 'طرح درس',
      icon: FontAwesomeIcons.chalkboardTeacher,
      url:
          'https://itarbiatbadani.ir/product-category/%d8%b7%d8%b1%d8%ad-%d8%af%d8%b1%d8%b3-%d8%b1%d9%88%d8%b2%d8%a7%d9%86%d9%87-%d9%85%d8%a7%d9%87%d8%a7%d9%86%d9%87-%d8%b3%d8%a7%d9%84%d8%a7%d9%86%d9%87/',
    ),
    ServiceItem(
      title: 'پاورپوینت',
      icon: FontAwesomeIcons.filePowerpoint,
      url:
          'https://itarbiatbadani.ir/product-category/powerpoint/',
    ),
  ];

  Future<void> open(String url) async {
    if (url.isEmpty) return;

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = services[index];

          return InkWell(
            onTap: () => open(item.url),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 125,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff102a3e),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xfffbc531)
                      .withOpacity(.15),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  FaIcon(
                    item.icon,
                    color:
                        const Color(0xfffbc531),
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/wordpress_api.dart';
import '../widgets/post_card.dart';
import '../widgets/service_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> postsFuture;

  @override
  void initState() {
    super.initState();

    postsFuture = WordPressApi.getPosts(
      perPage: 6,
    );
  }

  Future<void> open(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff07131f),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            postsFuture =
                WordPressApi.getPosts(
              perPage: 6,
            );
          });

          await postsFuture;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 105,
              backgroundColor:
                  const Color(0xff0a3d62),
              flexibleSpace:
                  FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.only(
                  right: 16,
                  bottom: 14,
                ),
                title: Row(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8),
                      child: Image.network(
                        'https://itarbiatbadani.ir/wp-content/uploads/2025/07/1000073463.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(
                          Icons.sports,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'تربیت بدنی و علوم ورزشی',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SearchPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: _HeroSection(
                onOpen: open,
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  12,
                ),
                child: Text(
                  'خدمات ما',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: ServiceCards(),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  28,
                  16,
                  14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.article_rounded,
                      color:
                          Color(0xfffbc531),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'جدیدترین نوشته‌ها',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            FutureBuilder<List<dynamic>>(
              future: postsFuture,
              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.all(40),
                      child: Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              Color(0xfffbc531),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: _ErrorBox(
                      onRetry: () {
                        setState(() {
                          postsFuture =
                              WordPressApi
                                  .getPosts(
                            perPage: 6,
                          );
                        });
                      },
                    ),
                  );
                }

                final posts =
                    snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'نوشته‌ای پیدا نشد',
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  sliver:
                      SliverList.builder(
                    itemCount: posts.length,
                    itemBuilder:
                        (context, index) {
                      return PostCard(
                        post: posts[index],
                      );
                    },
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
              child: _SocialSection(
                onOpen: open,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Future<void> Function(String) onOpen;

  const _HeroSection({
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        0,
      ),
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0a3d62),
            Color(0xff102a3e),
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xfffbc531)
              .withOpacity(.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const FaIcon(
            FontAwesomeIcons.medal,
            color: Color(0xfffbc531),
            size: 30,
          ),
          const SizedBox(height: 12),
          const Text(
            'مرجع تخصصی تربیت بدنی و علوم ورزشی',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اخبار، آموزش، منابع دانشگاهی، طرح درس و مطالب علمی ورزش',
            style: TextStyle(
              color: Color(0xffb8c7d4),
              height: 1.8,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialSection extends StatelessWidget {
  final Future<void> Function(String) onOpen;

  const _SocialSection({
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.all(16),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff0d2233),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'ما را دنبال کنید',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => onOpen(
                  'https://t.me/itarbiatbadani',
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.telegram,
                  color: Color(0xff25aee4),
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              IconButton(
                onPressed: () => onOpen(
                  'https://instagram.com/itarbiatbadani',
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBox({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 45,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          const Text(
            'دریافت مطالب سایت با مشکل مواجه شد.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text('تلاش دوباره'),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SearchScreen(),
    );
  }
}
import 'package:flutter/material.dart';

import '../services/wordpress_api.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  late Future<List<dynamic>> categoriesFuture;

  @override
  void initState() {
    super.initState();

    categoriesFuture =
        WordPressApi.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff07131f),
      appBar: AppBar(
        title: const Text(
          'دسته‌بندی مطالب',
        ),
        backgroundColor:
            const Color(0xff0a3d62),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: categoriesFuture,
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xfffbc531),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    categoriesFuture =
                        WordPressApi
                            .getCategories();
                  });
                },
                child:
                    const Text('تلاش دوباره'),
              ),
            );
          }

          final categories =
              snapshot.data ?? [];

          final mainCategories =
              categories.where((category) {
            return category['parent'] == 0;
          }).toList();

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                mainCategories.length,
            itemBuilder:
                (context, index) {
              final category =
                  mainCategories[index];

              return _CategoryTile(
                category: category,
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final dynamic category;

  const _CategoryTile({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff0d2233),
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.category_rounded,
          color: Color(0xfffbc531),
        ),
        title: Text(
          category['name'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SubCategoriesScreen(
                parentId:
                    category['id'],
                title:
                    category['name'] ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}

class SubCategoriesScreen
    extends StatelessWidget {
  final int parentId;
  final String title;

  const SubCategoriesScreen({
    super.key,
    required this.parentId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff07131f),
      appBar: AppBar(
        backgroundColor:
            const Color(0xff0a3d62),
        title: Text(title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future:
            WordPressApi.getSubCategories(
          parentId,
        ),
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xfffbc531),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'خطا در دریافت زیر دسته‌ها',
              ),
            );
          }

          final subCategories =
              snapshot.data ?? [];

          if (subCategories.isEmpty) {
            return const Center(
              child: Text(
                'برای این دسته زیر دسته‌ای ثبت نشده است.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                subCategories.length,
            itemBuilder:
                (context, index) {
              final item =
                  subCategories[index];

              return Card(
                color:
                    const Color(0xff0d2233),
                child: ListTile(
                  leading: const Icon(
                    Icons.folder_rounded,
                    color:
                        Color(0xfffbc531),
                  ),
                  title: Text(
                    item['name'] ?? '',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryPostsScreen(
                          categoryId:
                              item['id'],
                          title:
                              item['name'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryPostsScreen
    extends StatelessWidget {
  final int categoryId;
  final String title;

  const CategoryPostsScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff07131f),
      appBar: AppBar(
        backgroundColor:
            const Color(0xff0a3d62),
        title: Text(title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future:
            WordPressApi.getPosts(
          category: categoryId,
          perPage: 20,
        ),
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xfffbc531),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'خطا در دریافت مطالب',
              ),
            );
          }

          final posts =
              snapshot.data ?? [];

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder:
                (context, index) {
              final post = posts[index];

              return _SimplePost(
                post: post,
              );
            },
          );
        },
      ),
    );
  }
}

class _SimplePost extends StatelessWidget {
  final dynamic post;

  const _SimplePost({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff0d2233),
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.article_rounded,
          color: Color(0xfffbc531),
        ),
        title: Text(
          post['title']?['rendered'] ??
              '',
          maxLines: 3,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new,
          size: 15,
        ),
        onTap: () {
          // لینک مقاله از API
          // در PostCard نیز استفاده شده است.
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../services/wordpress_api.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController controller =
      TextEditingController();

  List<dynamic> results = [];

  bool loading = false;

  Future<void> search() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final data =
          await WordPressApi.getPosts(
        search: text,
        perPage: 20,
      );

      setState(() {
        results = data;
      });
    } catch (_) {
      setState(() {
        results = [];
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff07131f),
      appBar: AppBar(
        backgroundColor:
            const Color(0xff0a3d62),
        title: const Text(
          'جستجو در مطالب',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration:
                  InputDecoration(
                hintText:
                    'جستجوی مقاله...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    IconButton(
                  onPressed: search,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                ),
                filled: true,
                fillColor:
                    const Color(0xff0d2233),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          if (loading)
            const Padding(
              padding:
                  EdgeInsets.all(20),
              child:
                  CircularProgressIndicator(
                color: Color(0xfffbc531),
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: results.length,
              itemBuilder:
                  (context, index) {
                return PostCard(
                  post: results[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
