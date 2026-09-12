import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A3D62),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  int selectedBottomIndex = 0;

  final List<String> categories = [
    'همه',
    'تربیت بدنی',
    'علوم ورزشی',
    'ورزش',
    'آموزش',
    'طرح درس',
  ];

  final List<Article> articles = const [
    Article(
      title: 'جدیدترین مطالب تربیت بدنی و علوم ورزشی',
      category: 'علوم ورزشی',
      image:
          'https://itarbiatbadani.ir/wp-content/uploads/2025/07/1000073463.png',
    ),
    Article(
      title: 'ورزش و نقش آن در سلامت جسم و روان',
      category: 'ورزش',
      image:
          'https://itarbiatbadani.ir/wp-content/uploads/2025/07/1000073463.png',
    ),
    Article(
      title: 'آموزش و مباحث تخصصی تربیت بدنی',
      category: 'آموزش',
      image:
          'https://itarbiatbadani.ir/wp-content/uploads/2025/07/1000073463.png',
    ),
    Article(
      title: 'طرح درس تربیت بدنی و فعالیت‌های ورزشی',
      category: 'طرح درس',
      image:
          'https://itarbiatbadani.ir/wp-content/uploads/2025/07/1000073463.png',
    ),
  ];

  List<Article> get filteredArticles {
    if (selectedCategory == 0) {
      return articles;
    }

    final String category = categories[selectedCategory];

    return articles
        .where(
          (article) => article.category == category,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildCategories(),
              ),
              SliverToBoxAdapter(
                child: _buildHero(),
              ),
              SliverToBoxAdapter(
                child: _buildSectionTitle(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  24,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildArticleCard(
                        filteredArticles[index],
                      );
                    },
                    childCount: filteredArticles.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        14,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A3D62),
            Color(0xFF3C6382),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.network(
              'https://itarbiatbadani.ir/wp-content/uploads/2025/07/1000073463.png',
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.sports_soccer,
                  color: Color(0xFF0A3D62),
                  size: 30,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تربیت بدنی و علوم ورزشی',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'مرجع تخصصی ورزش و علوم ورزشی',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final Uri uri = Uri.parse(
                'https://itarbiatbadani.ir',
              );

              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 58,
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool selected = index == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF0A3D62)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF0A3D62)
                      : const Color(0xFFE0E4E8),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : const Color(0xFF34495E),
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A3D62),
            Color(0xFF3C6382),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرجع تخصصی',
                  style: TextStyle(
                    color: Color(0xFFFBC531),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'تربیت بدنی و\nعلوم ورزشی',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'آخرین مطالب، آموزش‌ها و منابع تخصصی ورزش',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFFFBC531),
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'جدیدترین نوشته‌ها',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF17202A),
              ),
            ),
          ),
          Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: Color(0xFF0A3D62),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(
          'https://itarbiatbadani.ir',
        );

        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                article.image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: const Color(0xFF0A3D62),
                    child: const Icon(
                      Icons.article,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category,
                      style: const TextStyle(
                        color: Color(0xFF0A3D62),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF17202A),
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          'مشاهده مطلب',
                          style: TextStyle(
                            color: Color(0xFF0A3D62),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_back,
                          size: 14,
                          color: Color(0xFF0A3D62),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: selectedBottomIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedBottomIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'خانه',
        ),
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: 'مطالب',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(Icons.shopping_bag),
          label: 'محصولات',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu),
          selectedIcon: Icon(Icons.menu),
          label: 'بیشتر',
        ),
      ],
    );
  }
}

class Article {
  final String title;
  final String category;
  final String image;

  const Article({
    required this.title,
    required this.category,
    required this.image,
  });
}
