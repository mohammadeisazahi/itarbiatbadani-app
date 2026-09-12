import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String siteUrl = 'https://itarbiatbadani.ir';
const String apiUrl = '$siteUrl/wp-json/wp/v2';

const String logoUrl =
    '$siteUrl/wp-content/uploads/2025/07/1000073463.png';

const String telegramUrl = 'https://t.me/itarbiatbadani';
const String instagramUrl = 'https://instagram.com/itarbiatbadani';
const String contactUrl = 'https://t.me/ivarzeshiadmin';
const String baleUrl = 'https://ble.ir/itarbiatbadani';

const Color primaryColor = Color(0xFF0A3D62);
const Color secondaryColor = Color(0xFF3C6382);
const Color goldColor = Color(0xFFFBC531);

void main() => runApp(const ItarbiatbadaniApp());

class ItarbiatbadaniApp extends StatelessWidget {
  const ItarbiatbadaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تربیت بدنی و علوم ورزشی',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'IRANSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class PostModel {
  final int id;
  final String title;
  final String excerpt;
  final String imageUrl;
  final String date;
  final String link;

  const PostModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.date,
    required this.link,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    String image = '';

    final embedded = json['_embedded'];

    if (embedded is Map<String, dynamic>) {
      final media = embedded['wp:featuredmedia'];

      if (media is List &&
          media.isNotEmpty &&
          media.first is Map) {
        image = media.first['source_url']?.toString() ?? '';
      }
    }

    return PostModel(
      id: json['id'] ?? 0,
      title: cleanHtml(
        json['title']?['rendered']?.toString() ?? '',
      ),
      excerpt: cleanHtml(
        json['excerpt']?['rendered']?.toString() ?? '',
      ),
      imageUrl: image,
      date: json['date']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final int parent;
  final int count;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.parent,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: cleanHtml(
        json['name']?.toString() ?? '',
      ),
      parent: json['parent'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}

class WordPressApi {
  static Future<List<PostModel>> latestPosts() async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/posts?per_page=6&orderby=date&order=desc&_embed',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception();
    }

    final data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception();
    }

    return data
        .map((e) => PostModel.fromJson(e))
        .toList();
  }

  static Future<List<CategoryModel>> categories() async {
    final result = <CategoryModel>[];

    var page = 1;

    while (true) {
      final response = await http.get(
        Uri.parse(
          '$apiUrl/categories?per_page=100&hide_empty=false&page=$page',
        ),
      );

      if (response.statusCode == 400) {
        break;
      }

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception();
      }

      result.addAll(
        data.map(
          (e) => CategoryModel.fromJson(e),
        ),
      );

      if (data.length < 100) {
        break;
      }

      page++;
    }

    result.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return result;
  }

  static Future<List<PostModel>> postsByCategory(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/posts?categories=$id&per_page=30&orderby=date&order=desc&_embed',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception();
    }

    final data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception();
    }

    return data
        .map((e) => PostModel.fromJson(e))
        .toList();
  }
}

Future<void> openUrl(String url) async {
  if (url.isEmpty) {
    return;
  }

  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    CategoriesPage(),
    StorePage(),
    TelegramPage(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor:
            primaryColor.withValues(alpha: .12),
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          setState(() {
            currentIndex = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'دسته‌بندی',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'فروشگاه',
          ),
          NavigationDestination(
            icon: Icon(Icons.telegram),
            selectedIcon: Icon(Icons.telegram),
            label: 'تلگرام',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open),
            label: 'بیشتر',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> future;

  @override
  void initState() {
    super.initState();
    future = WordPressApi.latestPosts();
  }

  Future<void> refresh() async {
    setState(() {
      future = WordPressApi.latestPosts();
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: _SkyHeader(),
            ),
            const SliverToBoxAdapter(
              child: _CategoryStrip(),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<PostModel>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 240,
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return ErrorBox(
                      message:
                          'دریافت نوشته‌ها با مشکل مواجه شد.',
                      retry: refresh,
                    );
                  }

                  final posts =
                      snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return const EmptyBox(
                      message:
                          'نوشته‌ای پیدا نشد.',
                    );
                  }

                  return _HomeNews(
                    posts: posts,
                  );
                },
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

class _SkyHeader extends StatelessWidget {
  const _SkyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding:
          const EdgeInsets.fromLTRB(
        18,
        54,
        18,
        18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                padding:
                    const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تربیت بدنی و علوم ورزشی',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'مرجع تخصصی تربیت بدنی و علوم ورزشی',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'جدیدترین مطالب، منابع و محتوای تخصصی',
            style: TextStyle(
              color: Colors.white
                  .withValues(alpha: .82),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) {
    final items = [
      ['جدیدترین', Icons.bolt],
      ['علوم ورزشی', Icons.fitness_center],
      ['تربیت بدنی', Icons.sports],
      ['ارشد', Icons.school],
      ['دکتری', Icons.menu_book],
      ['طرح درس', Icons.description],
    ];

    return Container(
      height: 62,
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: i == 0
                  ? primaryColor
                  : const Color(0xFFF1F3F5),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  items[i][1] as IconData,
                  size: 17,
                  color: i == 0
                      ? Colors.white
                      : primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  items[i][0] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color: i == 0
                        ? Colors.white
                        : const Color(
                            0xFF263238,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeNews extends StatelessWidget {
  final List<PostModel> posts;

  const _HomeNews({
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    final hero = posts.first;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        18,
        14,
        0,
      ),
      child: Column(
        children: [
          _HeroPost(post: hero),
          const SizedBox(height: 22),
          const SectionTitle(
            title: 'جدیدترین مطالب',
            icon: Icons.article_outlined,
          ),
          const SizedBox(height: 12),
          ...posts
              .skip(1)
              .map(
                (p) => PostCard(post: p),
              ),
        ],
      ),
    );
  }
}

class _HeroPost extends StatelessWidget {
  final PostModel post;

  const _HeroPost({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openUrl(
        post.link.isNotEmpty
            ? post.link
            : '$siteUrl/?p=${post.id}',
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(14),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.55,
              child: post.imageUrl.isEmpty
                  ? Container(
                      color: primaryColor,
                      child: const Icon(
                        Icons.article,
                        color: Colors.white,
                        size: 60,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl:
                          post.imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: .82,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 14,
              left: 14,
              bottom: 14,
              child: Text(
                post.title,
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  height: 1.45,
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: goldColor,
                  borderRadius:
                      BorderRadius.circular(7),
                ),
                child: const Text(
                  'ویژه',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 11,
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

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 11),
      elevation: 1,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: InkWell(
        onTap: () => openUrl(
          post.link.isNotEmpty
              ? post.link
              : '$siteUrl/?p=${post.id}',
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(9),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: SizedBox(
                  width: 112,
                  height: 88,
                  child: post.imageUrl.isEmpty
                      ? Container(
                          color: primaryColor
                              .withValues(
                            alpha: .08,
                          ),
                          child: const Icon(
                            Icons.article,
                            color:
                                primaryColor,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl:
                              post.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget:
                              (_, __, ___) =>
                                  const Icon(
                            Icons
                                .broken_image_outlined,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                        height: 1.45,
                      ),
                    ),
                    if (post.excerpt
                        .isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        post.excerpt,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons
                              .arrow_back_ios_new,
                          size: 12,
                          color: primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'مشاهده مطلب',
                          style: TextStyle(
                            color:
                                primaryColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                primaryColor.withValues(
              alpha: .1,
            ),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() =>
      _CategoriesPageState();
}

class _CategoriesPageState
    extends State<CategoriesPage> {
  late Future<List<CategoryModel>>
      futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories =
        WordPressApi.categories();
  }

  Future<void> refresh() async {
    setState(() {
      futureCategories =
          WordPressApi.categories();
    });

    await futureCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('دسته‌بندی‌ها'),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder<
            List<CategoryModel>>(
          future: futureCategories,
          builder:
              (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ErrorBox(
                message:
                    'دریافت دسته‌بندی‌ها با مشکل مواجه شد.',
                retry: refresh,
              );
            }

            final categories =
                snapshot.data ?? [];

            // فقط دسته‌های اصلی وردپرس
            // parent == 0
            final mainCategories =
                categories
                    .where(
                      (category) =>
                          category.parent ==
                          0,
                    )
                    .toList();

            if (mainCategories.isEmpty) {
              return const EmptyBox(
                message:
                    'دسته‌بندی اصلی پیدا نشد.',
              );
            }

            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(14),
              children: [
                const SectionTitle(
                  title:
                      'موضوعات',
                  icon:
                      Icons.category_outlined,
                ),
                const SizedBox(
                  height: 12,
                ),

                // فقط دسته‌های اصلی
                ...mainCategories.map(
                  (category) =>
                      _MainCategoryTile(
                    category: category,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MainCategoryTile
    extends StatelessWidget {
  final CategoryModel category;

  const _MainCategoryTile({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        leading: const CategoryIcon(),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight:
                FontWeight.w800,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${category.count} مطلب',
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: primaryColor,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CategoryPostsPage(
                category: category,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryIcon
    extends StatelessWidget {
  const CategoryIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color:
            primaryColor.withValues(
          alpha: .1,
        ),
        borderRadius:
            BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.folder_outlined,
        color: primaryColor,
      ),
    );
  }
}

class CategoryPostsPage
    extends StatelessWidget {
  final CategoryModel category;

  const CategoryPostsPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: FutureBuilder<
          List<PostModel>>(
        future:
            WordPressApi.postsByCategory(
          category.id,
        ),
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const ErrorBox(
              message:
                  'دریافت مطالب این دسته‌بندی با مشکل مواجه شد.',
            );
          }

          final posts =
              snapshot.data ?? [];

          if (posts.isEmpty) {
            return const EmptyBox(
              message:
                  'در این دسته‌بندی مطلبی پیدا نشد.',
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(14),
            itemCount: posts.length,
            itemBuilder: (_, i) =>
                PostCard(
              post: posts[i],
            ),
          );
        },
      ),
    );
  }
}

class StorePage
    extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('فروشگاه'),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const _BigIcon(
                icon:
                    Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 18),
              const Text(
                'فروشگاه تربیت بدنی و علوم ورزشی',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'برای مشاهده محصولات و خرید، وارد فروشگاه سایت شوید.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () =>
                    openUrl(
                  '$siteUrl/shop/',
                ),
                icon: const Icon(
                  Icons.storefront,
                ),
                label: const Text(
                  'ورود به فروشگاه',
                ),
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelegramPage
    extends StatelessWidget {
  const TelegramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('تلگرام'),
      ),
      body: SocialChannelPage(
        title: 'کانال تلگرام',
        username: '@itarbiatbadani',
        icon: Icons.telegram,
        url: telegramUrl,
      ),
    );
  }
}

class BalePage
    extends StatelessWidget {
  const BalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SocialChannelPage(
        title: 'کانال بله',
        username: 'کانال بله',
        icon: Icons.chat_outlined,
        url: baleUrl,
      ),
    );
  }
}

class SocialChannelPage
    extends StatelessWidget {
  final String title;
  final String username;
  final IconData icon;
  final String url;

  const SocialChannelPage({
    super.key,
    required this.title,
    required this.username,
    required this.icon,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            _BigIcon(icon: icon),
            const SizedBox(height: 18),
            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              username,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  openUrl(url),
              icon: Icon(icon),
              label: const Text(
                'ورود به کانال',
              ),
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MorePage
    extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('بیشتر'),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(14),
        children: [
          const AboutCard(),
          const SizedBox(height: 12),

          MoreItem(
            icon: Icons.language,
            title: 'وب‌سایت',
            subtitle:
                'itarbiatbadani.ir',
            onTap: () =>
                openUrl(siteUrl),
          ),

          MoreItem(
            icon:
                Icons.camera_alt_outlined,
            title: 'اینستاگرام',
            subtitle:
                '@itarbiatbadani',
            onTap: () =>
                openUrl(instagramUrl),
          ),

          MoreItem(
            icon: Icons.support_agent,
            title: 'تماس و سفارش',
            subtitle:
                '@ivarzeshiadmin',
            onTap: () =>
                openUrl(contactUrl),
          ),

          MoreItem(
            icon: Icons.chat_outlined,
            title: 'بله',
            subtitle: 'کانال بله',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const BalePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutCard
    extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              padding:
                  const EdgeInsets.all(7),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Image.network(
                logoUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'تربیت بدنی و علوم ورزشی',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'مرجع تخصصی تربیت بدنی و علوم ورزشی',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MoreItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration:
              BoxDecoration(
            color:
                primaryColor.withValues(
              alpha: .1,
            ),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_back_ios_new,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BigIcon
    extends StatelessWidget {
  final IconData icon;

  const _BigIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      height: 95,
      decoration: BoxDecoration(
        color:
            primaryColor.withValues(
          alpha: .1,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: primaryColor,
        size: 52,
      ),
    );
  }
}

class ErrorBox
    extends StatelessWidget {
  final String message;
  final VoidCallback? retry;

  const ErrorBox({
    super.key,
    required this.message,
    this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color:
                  Colors.red.shade400,
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
            if (retry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: retry,
                child:
                    const Text(
                  'تلاش مجدد',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyBox
    extends StatelessWidget {
  final String message;

  const EmptyBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.all(35),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 45,
              color:
                  Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String cleanHtml(String text) {
  return text
      .replaceAll(
        RegExp(r'<[^>]*>'),
        '',
      )
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&#8217;', '’')
      .replaceAll('&#8220;', '“')
      .replaceAll('&#8221;', '”')
      .replaceAll(
        RegExp(r'\s+'),
        ' ',
      )
      .trim();
}
