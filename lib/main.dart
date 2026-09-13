import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String site = 'https://itarbiatbadani.ir';
const String api = '$site/wp-json/wp/v2';
const Color gold = Color(0xfffbc531);
const Color bgC = Color(0xff07131f);
const Color pnl = Color(0xff0d2233);
const Color pnl2 = Color(0xff102a3e);
const Color txtC = Color(0xfff4f7fa);
const Color mutC = Color(0xff9fb0bd);
const String logo = 'assets/images/logo.png';
const String logoNet = '$site/wp-content/uploads/2025/07/1000073463.png';

class Cat {
  final String n;
  final String s;
  final IconData i;
  const Cat(this.n, this.s, this.i);
}

const cats = <Cat>[
  Cat('رشته تربیت بدنی و علوم ورزشی', 'physical-education-sport-sciences', Icons.sports_soccer),
  Cat('علوم ورزشی', 'sports-science', Icons.science_outlined),
  Cat('منابع آزمون‌های علوم ورزشی', 'sports-science-exam-resources', Icons.menu_book_outlined),
  Cat('تغذیه ورزشی', 'sports-nutrition', Icons.restaurant_outlined),
  Cat('اخبار و رویدادها', 'sports-news-and-events', Icons.newspaper_outlined),
  Cat('ورزش همگانی، سلامت و تندرستی', 'public-exercise-health-and-wellness', Icons.favorite_outline),
  Cat('پژوهش در تربیت بدنی', 'research-in-physical-education', Icons.search_outlined),
  Cat('تربیت بدنی و آموزش', 'physical-education-and-training', Icons.school_outlined),
  Cat('معرفی منابع و کتب مرجع', 'introduction-to-sources-and-reference-books', Icons.library_books_outlined),
  Cat('اصول ورزش و فعالیت بدنی', 'principles-of-exercise-and-physical-activity', Icons.fitness_center_outlined),
  Cat('آزمون‌های استخدامی', 'employment-tests', Icons.assignment_outlined),
  Cat('معرفی رشته‌های ورزشی', 'introduction-to-sports-disciplines', Icons.sports_handball_outlined),
  Cat('ورزش برای گروه‌ها و نیازهای ویژه', 'exercise-for-special-groups-and-needs', Icons.accessibility_new_outlined),
  Cat('فناوری و نوآوری در ورزش', 'technology-and-innovation-in-sports-sports-science', Icons.memory_outlined),
];

Future<void> openUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String clean(String v) => v
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .trim();

String pTitle(dynamic p) {
  try { return clean(p['title']['rendered'] ?? ''); } catch (_) { return ''; }
}

String pLink(dynamic p) {
  try { return p['link'] ?? ''; } catch (_) { return ''; }
}

String pImg(dynamic p) {
  try {
    final m = p['_embedded']?['wp:featuredmedia'];
    if (m is List && m.isNotEmpty) return m[0]['source_url'] ?? '';
  } catch (_) {}
  return '';
}

Future<List> getPosts() async {
  final r = await http.get(Uri.parse('$api/posts?per_page=6&_embed'));
  if (r.statusCode == 200) return json.decode(r.body);
  throw Exception('خطای ${r.statusCode}');
}

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تربیت بدنی و علوم ورزشی',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgC,
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
      ),
      builder: (c, ch) => Directionality(
        textDirection: TextDirection.rtl,
        child: ch ?? const SizedBox(),
      ),
      home: const Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _i,
        children: const [
          Home(),
          CatsPage(),
          NewsPage(),
          SizedBox(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (i) {
          if (i == 3) {
            openUrl('$site/shop/');
            return;
          }
          setState(() => _i = i);
        },
        backgroundColor: const Color(0xff081925),
        selectedItemColor: gold,
        unselectedItemColor: mutC,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'دسته‌ها'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), label: 'اخبار'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'فروشگاه'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حساب من'),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List>? _f;
  @override
  void initState() {
    super.initState();
    _f = getPosts();
  }
  Future<void> _refresh() async {
    setState(() => _f = getPosts());
    try { await _f; } catch (_) {}
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: gold,
      backgroundColor: pnl,
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _header(context)),
          SliverToBoxAdapter(child: _hero()),
          SliverToBoxAdapter(child: _services()),
          const SliverToBoxAdapter(
            child: _SectionTitle('جدیدترین نوشته‌ها', Icons.article_outlined),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List>(
              future: _f,
              builder: (c, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const _Loading();
                }
                if (s.hasError) {
                  return _ErrorBox('خطا در دریافت مطالب.\n${s.error}', _refresh);
                }
                final posts = s.data ?? [];
                if (posts.isEmpty) return const _Empty('مطلبی پیدا نشد.');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: posts.map((p) => _post(context, p)).toList(),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionTitle('دسته‌بندی مطالب', Icons.grid_view_rounded),
          ),
          SliverToBoxAdapter(child: _catGrid()),
          SliverToBoxAdapter(child: _social()),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}

class CatsPage extends StatelessWidget {
  const CatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _header(context, 'دسته‌بندی مطالب'),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: cats.map((c) => _catTile(context, c)).toList(),
          ),
        ),
      ],
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(title: const Text('اخبار و رویدادها'), backgroundColor: bgC),
        Expanded(
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () => openUrl('$site/category/sports-news-and-events/'),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('مشاهده اخبار در مرورگر'),
            ),
          ),
        ),
      ],
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(title: const Text('حساب من'), backgroundColor: bgC),
        const Expanded(
          child: Center(
            child: Text('به زودی...', style: TextStyle(color: txtC)),
          ),
        ),
      ],
    );
  }
}

Widget _header(BuildContext context, [String t = 'تربیت بدنی و علوم ورزشی']) {
  return SafeArea(
    bottom: false,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: bgC,
        border: Border(bottom: BorderSide(color: Color(0x17ffffff))),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(
                  logoNet,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.sports, color: gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t,
              textAlign: TextAlign.right,
              style: const TextStyle(color: txtC, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => openUrl('$site/?s='),
            icon: const Icon(Icons.search, color: gold, size: 27),
          ),
        ],
      ),
    ),
  );
}

Widget _hero() {
  return Container(
    margin: const EdgeInsets.fromLTRB(14, 18, 14, 10),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xff0a3d62), Color(0xff102a3e)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: gold.withOpacity(0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: gold.withOpacity(0.5), width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  logo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, color: gold, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تربیت بدنی و علوم ورزشی',
                textAlign: TextAlign.right,
                style: TextStyle(color: gold, fontSize: 17, fontWeight: FontWeight.bold),
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
          'دسترسی سریع به جدیدترین اخبار، منابع علمی، طرح درس، پاورپوینت‌های آموزشی و مطالب تخصصی.',
          textAlign: TextAlign.right,
          style: TextStyle(color: Color(0xffc5d4df), fontSize: 13, height: 1.9),
        ),
      ],
    ),
  );
}

Widget _services() {
  final items = [
    ['معرفی رشته', Icons.info_outline, '$site/introduction-to-the-field-of-physical-education-and-sports-sciences/'],
    ['گرایش‌های ارشد', Icons.school_outlined, '$site/master-of-sports-science-resources/'],
    ['گرایش‌های دکتری', Icons.account_balance_outlined, '$site/sports-science-phd-exam-resources/'],
    ['منابع ارشد', Icons.menu_book_outlined, '$site/master-of-sports-science-resources/'],
    ['منابع دکتری', Icons.library_books_outlined, '$site/manabe-konkur-doctori-tarbiat-badani/'],
    ['دانشگاه‌های برتر', Icons.account_balance, '$site/physical-education-sports-science/'],
    ['بازار کار', Icons.work_outline, '$site/job-market-in-physical-education-and-sports-sciences/'],
    ['طرح درس', Icons.assignment_outlined, '$site/product-category/%d8%b7%d8%b1%d8%ad-%d8%af%d8%b1%d8%b3/'],
    ['پاورپوینت', Icons.slideshow_outlined, '$site/product-category/powerpoint/'],
  ];
  return Column(
    children: [
      const _SectionTitle('خدمات ما', Icons.apps),
      SizedBox(
        height: 112,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (c, i) => GestureDetector(
            onTap: () => openUrl(items[i][2] as String),
            child: Container(
              width: 112,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: pnl,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i][1] as IconData, color: gold, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    items[i][0] as String,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: txtC, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget _post(BuildContext context, dynamic p) {
  final i = pImg(p);
  return GestureDetector(
    onTap: () => openUrl(pLink(p)),
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: pnl,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: SizedBox(
              width: 125, height: 110,
              child: i.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: i,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: pnl2,
                        child: const Icon(Icons.article_outlined, color: gold, size: 40),
                      ),
                    )
                  : Container(
                      color: pnl2,
                      child: const Icon(Icons.article_outlined, color: gold, size: 40),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Text(
                pTitle(p),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(color: txtC, fontSize: 14, fontWeight: FontWeight.bold, height: 1.7),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _catGrid() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (c, i) => GestureDetector(
        onTap: () => openUrl('$site/category/${cats[i].s}/'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pnl,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cats[i].i, color: gold, size: 24),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: Text(
                    cats[i].n,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: txtC, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _catTile(BuildContext context, Cat c) {
  return GestureDetector(
    onTap: () => openUrl('$site/category/${c.s}/'),
    child: Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: pnl,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(c.i, color: gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              c.n,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: txtC, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
          const Icon(Icons.arrow_back_ios, color: mutC, size: 16),
        ],
      ),
    ),
  );
}

Widget _social() {
  final items = [
    ['تلگرام', Icons.send, 'https://t.me/itarbiatbadani'],
    ['اینستاگرام', Icons.camera_alt_outlined, 'https://instagram.com/itarbiatbadani'],
    ['بله', Icons.chat_outlined, 'https://ble.ir/itarbiatbadani'],
    ['فروشگاه', Icons.shopping_cart, '$site/shop/'],
  ];
  return Column(
    children: [
      const _SectionTitle('ارتباط با ما', Icons.connect_without_contact),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3.2,
          ),
          itemBuilder: (c, i) => GestureDetector(
            onTap: () => openUrl(items[i][2] as String),
            child: Container(
              decoration: BoxDecoration(
                color: pnl,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i][1] as IconData, color: gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    items[i][0] as String,
                    style: const TextStyle(color: txtC, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String t;
  final IconData i;
  const _SectionTitle(this.t, this.i);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      child: Row(
        children: [
          Container(
            width: 4, height: 25,
            decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 9),
          Icon(i, color: gold, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t,
              textAlign: TextAlign.right,
              style: const TextStyle(color: txtC, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(35),
        child: Center(child: CircularProgressIndicator(color: gold)),
      );
}

class _Empty extends StatelessWidget {
  final String t;
  const _Empty(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Center(child: Text(t, style: const TextStyle(color: mutC))),
      );
}

class _ErrorBox extends StatelessWidget {
  final String m;
  final VoidCallback? r;
  const _ErrorBox(this.m, this.r);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(m, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          if (r != null) ...[
            const SizedBox(height: 15),
            ElevatedButton(onPressed: r, child: const Text('تلاش مجدد')),
          ],
        ],
      ),
    );
  }
}
