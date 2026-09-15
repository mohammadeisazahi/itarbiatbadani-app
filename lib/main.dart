import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String site = 'https://itarbiatbadani.ir';
const String api = '$site/wp-json/wp/v2';
const String wcKey = 'YOUR_WC_KEY';
const String wcSecret = 'YOUR_WC_SECRET';
const Color gold = Color(0xfffbc531);
const Color bgC = Color(0xff07131f);
const Color pnl = Color(0xff0d2233);
const Color pnl2 = Color(0xff102a3e);
const Color txtC = Color(0xfff4f7fa);
const Color mutC = Color(0xff9fb0bd);
const String logo = 'assets/images/logo.png';
const String logoNet = '$site/wp-content/uploads/2025/07/1000073463.png';
const String heroImg = '$site/wp-content/uploads/2025/08/file_00000000b12862439589872d238e031b-1.png';
const int perPageSize = 10;

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
    .replaceAll('&#8217;', '’')
    .replaceAll('&#8220;', '“')
    .replaceAll('&#8221;', '”')
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

String pDate(dynamic p) {
  try {
    final d = DateTime.parse(p['date']).toLocal();
    final j = _toJalali(d.year, d.month, d.day);
    return '${j[0]}/${j[1].toString().padLeft(2, '0')}/${j[2].toString().padLeft(2, '0')}';
  } catch (_) { return ''; }
}

List<int> _toJalali(int gy, int gm, int gd) {
  const gdm = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  const jdm = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
  var gy2 = (gm > 2) ? (gy + 1) : gy;
  var days = 355666 + (365 * gy) + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) + gd;
  for (var i = 0; i < gm - 1; i++) days += gdm[i];
  var jy = -1595 + (33 * (days ~/ 12053));
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) { jy += (days - 1) ~/ 365; days = (days - 1) % 365; }
  var jm = 0;
  var jd = days + 1;
  for (var i = 0; i < 12; i++) {
    if (jd <= jdm[i]) { jm = i + 1; break; }
    jd -= jdm[i];
  }
  return [jy, jm, jd];
}

Future<List> getPostsPaged({int perPage = perPageSize, int page = 1, int? catId}) async {
  var u = '$api/posts?per_page=$perPage&page=$page&_embed=wp:featuredmedia';
  if (catId != null) u += '&categories=$catId';
  final r = await http.get(Uri.parse(u));
  if (r.statusCode == 400) return [];
  if (r.statusCode != 200) throw Exception('خطای ${r.statusCode}');
  return json.decode(r.body) as List;
}

Future<List> getProductsPaged({int perPage = perPageSize, int page = 1}) async {
  final u = '$site/wp-json/wc/v3/products?per_page=$perPage&page=$page&consumer_key=$wcKey&consumer_secret=$wcSecret';
  final r = await http.get(Uri.parse(u));
  if (r.statusCode == 400) return [];
  if (r.statusCode != 200) throw Exception('خطای ${r.statusCode}');
  return json.decode(r.body) as List;
}

Future<int?> getCatIdBySlug(String slug) async {
  try {
    final r = await http.get(Uri.parse('$api/categories?slug=$slug'));
    if (r.statusCode == 200) {
      final list = json.decode(r.body);
      if (list is List && list.isNotEmpty) return list[0]['id'];
    }
  } catch (_) {}
  return null;
}

Future<List> searchExact(String query) async {
  final r = await http.get(
    Uri.parse('$api/posts?search=${Uri.encodeComponent(query)}&per_page=50&_embed=wp:featuredmedia'),
  );
  if (r.statusCode != 200) throw Exception('خطای ${r.statusCode}');
  final list = json.decode(r.body) as List;
  final words = query.trim().toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  return list.where((p) {
    final title = clean((p['title']?['rendered'] ?? '')).toLowerCase();
    return words.every((w) => title.contains(w));
  }).toList();
}

String formatPrice(String price) {
  if (price.isEmpty) return '';
  final n = int.tryParse(price);
  if (n == null) return price;
  final s = n.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return '$buffer تومان';
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
        fontFamily: 'Vazirmatn',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgC,
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
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
        children: const [Home(), ArticlesPage(), NewsPage(), ShopPage(), AccountPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (i) => setState(() => _i = i),
        backgroundColor: const Color(0xff081925),
        selectedItemColor: gold,
        unselectedItemColor: mutC,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'مقالات'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), activeIcon: Icon(Icons.newspaper), label: 'اخبار'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'فروشگاه'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حساب من'),
        ],
      ),
    );
  }
}

/* ==================== HOME ==================== */
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
    _f = getPostsPaged(perPage: 6, page: 1);
  }
  Future<void> _refresh() async {
    setState(() => _f = getPostsPaged(perPage: 6, page: 1));
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
                if (s.connectionState == ConnectionState.waiting) return const _Loading();
                if (s.hasError) return _ErrorBox('خطا در دریافت مطالب.\n${s.error}', _refresh);
                final posts = s.data ?? [];
                if (posts.isEmpty) return const _Empty('مطلبی پیدا نشد.');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(children: posts.map((p) => _post(context, p)).toList()),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionTitle('دسته‌بندی مقالات', Icons.grid_view_rounded),
          ),
          SliverToBoxAdapter(child: _catGrid()),
          SliverToBoxAdapter(child: _social()),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}

/* ==================== ARTICLES ==================== */
class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});
  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final _posts = <dynamic>[];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300 && !_loading && _hasMore) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      final list = await getPostsPaged(perPage: perPageSize, page: _page);
      setState(() {
        if (list.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(list);
          _page++;
          if (list.length < perPageSize) _hasMore = false;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _posts.clear(); _page = 1; _hasMore = true; _error = null; });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _header(context, 'مقالات'),
          Expanded(
            child: _posts.isEmpty && _loading
                ? const _Loading()
                : _posts.isEmpty && _error != null
                    ? _ErrorBox('خطا در دریافت مقالات.\n$_error', _refresh)
                    : _posts.isEmpty
                        ? const _Empty('مقاله‌ای پیدا نشد.')
                        : RefreshIndicator(
                            color: gold,
                            backgroundColor: pnl,
                            onRefresh: _refresh,
                            child: ListView.builder(
                              controller: _scroll,
                              cacheExtent: 800,
                              padding: const EdgeInsets.all(14),
                              itemCount: _posts.length + (_hasMore ? 1 : 0),
                              itemBuilder: (c, i) {
                                if (i >= _posts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(child: CircularProgressIndicator(color: gold)),
                                  );
                                }
                                return _post(context, _posts[i]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/* ==================== CATEGORY POSTS ==================== */
class CategoryPostsPage extends StatefulWidget {
  final Cat c;
  const CategoryPostsPage({super.key, required this.c});
  @override
  State<CategoryPostsPage> createState() => _CategoryPostsPageState();
}

class _CategoryPostsPageState extends State<CategoryPostsPage> {
  final _posts = <dynamic>[];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  int? _catId;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300 && !_loading && _hasMore) {
        _load();
      }
    });
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      _catId = await getCatIdBySlug(widget.c.s);
      if (_catId == null) throw Exception('دسته‌بندی یافت نشد');
      await _load();
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _load() async {
    if (_loading && _posts.isNotEmpty) return;
    if (!_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      final list = await getPostsPaged(perPage: perPageSize, page: _page, catId: _catId);
      setState(() {
        if (list.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(list);
          _page++;
          if (list.length < perPageSize) _hasMore = false;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _posts.clear(); _page = 1; _hasMore = true; _error = null; });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.c.n), backgroundColor: bgC),
      body: _posts.isEmpty && _loading
          ? const _Loading()
          : _posts.isEmpty && _error != null
              ? _ErrorBox('خطا در دریافت مطالب.\n$_error', _refresh)
              : _posts.isEmpty
                  ? const _Empty('مطلبی در این دسته پیدا نشد.')
                  : RefreshIndicator(
                      color: gold,
                      backgroundColor: pnl,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        controller: _scroll,
                        cacheExtent: 800,
                        padding: const EdgeInsets.all(14),
                        itemCount: _posts.length + (_hasMore ? 1 : 0),
                        itemBuilder: (c, i) {
                          if (i >= _posts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator(color: gold)),
                            );
                          }
                          return _post(context, _posts[i]);
                        },
                      ),
                    ),
    );
  }
}

/* ==================== NEWS ==================== */
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _posts = <dynamic>[];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  int? _catId;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _init();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300 && !_loading && _hasMore) {
        _load();
      }
    });
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      _catId = await getCatIdBySlug('sports-news-and-events');
      if (_catId == null) throw Exception('دسته‌بندی اخبار یافت نشد');
      await _load();
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _load() async {
    if (_loading && _posts.isNotEmpty) return;
    if (!_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      final list = await getPostsPaged(perPage: perPageSize, page: _page, catId: _catId);
      setState(() {
        if (list.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(list);
          _page++;
          if (list.length < perPageSize) _hasMore = false;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _posts.clear(); _page = 1; _hasMore = true; _error = null; });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(title: const Text('اخبار و رویدادها'), backgroundColor: bgC),
        Expanded(
          child: _posts.isEmpty && _loading
              ? const _Loading()
              : _posts.isEmpty && _error != null
                  ? _ErrorBox('خطا در دریافت اخبار.\n$_error', _refresh)
                  : _posts.isEmpty
                      ? const _Empty('خبری پیدا نشد.')
                      : RefreshIndicator(
                          color: gold,
                          backgroundColor: pnl,
                          onRefresh: _refresh,
                          child: ListView.builder(
                            controller: _scroll,
                            cacheExtent: 800,
                            padding: const EdgeInsets.all(14),
                            itemCount: _posts.length + (_hasMore ? 1 : 0),
                            itemBuilder: (c, i) {
                              if (i >= _posts.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(child: CircularProgressIndicator(color: gold)),
                                );
                              }
                              return _post(context, _posts[i]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

/* ==================== SHOP ==================== */
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _products = <dynamic>[];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300 && !_loading && _hasMore) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      final list = await getProductsPaged(perPage: perPageSize, page: _page);
      setState(() {
        if (list.isEmpty) {
          _hasMore = false;
        } else {
          _products.addAll(list);
          _page++;
          if (list.length < perPageSize) _hasMore = false;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refresh() async {
    setState(() { _products.clear(); _page = 1; _hasMore = true; _error = null; });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _header(context, 'فروشگاه'),
          Expanded(
            child: _products.isEmpty && _loading
                ? const _Loading()
                : _products.isEmpty && _error != null
                    ? _ErrorBox('خطا در دریافت محصولات.\n$_error', _refresh)
                    : _products.isEmpty
                        ? const _Empty('محصولی پیدا نشد.')
                        : RefreshIndicator(
                            color: gold,
                            backgroundColor: pnl,
                            onRefresh: _refresh,
                            child: ListView.builder(
                              controller: _scroll,
                              cacheExtent: 800,
                              padding: const EdgeInsets.all(14),
                              itemCount: _products.length + (_hasMore ? 1 : 0),
                              itemBuilder: (c, i) {
                                if (i >= _products.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(child: CircularProgressIndicator(color: gold)),
                                  );
                                }
                                return _product(context, _products[i]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/* ==================== SEARCH ==================== */
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  Future<List>? _f;
  String _q = '';

  void _doSearch() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _q = q;
      _f = searchExact(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جستجو'), backgroundColor: bgC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
              style: const TextStyle(color: txtC),
              decoration: InputDecoration(
                hintText: 'عبارت مورد نظر...',
                hintStyle: const TextStyle(color: mutC),
                filled: true,
                fillColor: pnl,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: gold),
                  onPressed: _doSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: _f == null
                ? const _Empty('عبارتی برای جستجو وارد کنید')
                : FutureBuilder<List>(
                    future: _f,
                    builder: (c, s) {
                      if (s.connectionState == ConnectionState.waiting) return const _Loading();
                      if (s.hasError) return _ErrorBox('خطا در جستجو.\n${s.error}', null);
                      final posts = s.data ?? [];
                      if (posts.isEmpty) return _Empty('نتیجه‌ای برای «$_q» پیدا نشد.');
                      return ListView.builder(
                        cacheExtent: 800,
                        padding: const EdgeInsets.all(14),
                        itemCount: posts.length,
                        itemBuilder: (c, i) => _post(context, posts[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/* ==================== ACCOUNT ==================== */
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            _header(context, 'حساب من'),
            Container(
              color: pnl,
              child: const TabBar(
                indicatorColor: gold,
                labelColor: gold,
                unselectedLabelColor: mutC,
                tabs: [
                  Tab(text: 'حساب من', icon: Icon(Icons.person_outline, size: 20)),
                  Tab(text: 'دسترسی سریع', icon: Icon(Icons.flash_on_outlined, size: 20)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const WebPage(
                    url: '$site/my-account/',
                    title: 'حساب من',
                    fullPage: false,
                  ),
                  ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: gold.withOpacity(0.4), width: 2),
                          ),
                          child: const Icon(Icons.person_outline, color: gold, size: 50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'دسترسی سریع',
                          style: TextStyle(color: txtC, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'برای دسترسی سریع به بخش‌های مهم حساب کاربری، از دکمه‌های زیر استفاده کنید.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: mutC, fontSize: 13, height: 1.8),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _accountBtn(context, 'ورود به حساب کاربری', Icons.login, '$site/my-account/'),
                      const SizedBox(height: 12),
                      _accountBtn(context, 'ثبت‌نام / فراموشی رمز', Icons.person_add_alt_1, '$site/my-account/'),
                      const SizedBox(height: 12),
                      _accountBtn(context, 'خریدهای من (دانلود فایل‌ها)', Icons.download_outlined, '$site/my-account/downloads/'),
                      const SizedBox(height: 12),
                      _accountBtn(context, 'سفارش‌های من', Icons.receipt_long_outlined, '$site/my-account/orders/'),
                      const SizedBox(height: 25),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'نکته: ثبت‌نام و ورود از طریق سامانه امن فروشگاه انجام می‌شود.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: mutC, fontSize: 11, height: 1.7),
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
    );
  }

  Widget _accountBtn(BuildContext context, String label, IconData icon, String url) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WebPage(url: url, title: label)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
              child: Icon(icon, color: gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: txtC, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: mutC, size: 16),
          ],
        ),
      ),
    );
  }
}

/* ==================== WEB PAGE ==================== */
class WebPage extends StatefulWidget {
  final String url;
  final String title;
  final bool fullPage;
  const WebPage({
    super.key,
    required this.url,
    required this.title,
    this.fullPage = false,
  });
  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _c;
  bool _l = true;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgC)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _l = true),
        onPageFinished: (_) => setState(() => _l = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      children: [
        WebViewWidget(controller: _c),
        if (_l) const Center(child: CircularProgressIndicator(color: gold)),
      ],
    );
    if (widget.fullPage) {
      return Scaffold(
        body: Column(
          children: [
            _header(context, widget.title),
            Expanded(child: content),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: bgC),
      body: content,
    );
  }
}

/* ==================== COMMON WIDGETS ==================== */
Widget _header(BuildContext context, [String? t]) {
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
              t ?? 'اپلیکیشن تربیت بدنی و علوم ورزشی',
              textAlign: TextAlign.right,
              style: const TextStyle(color: txtC, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => openUrl('$site/shop/'),
            icon: const Icon(Icons.shopping_cart_outlined, color: gold, size: 26),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
            icon: const Icon(Icons.search, color: gold, size: 26),
          ),
        ],
      ),
    ),
  );
}

Widget _hero() {
  return Container(
    margin: const EdgeInsets.fromLTRB(14, 18, 14, 10),
    decoration: BoxDecoration(
      color: pnl,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: gold.withOpacity(0.15)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        heroImg,
        fit: BoxFit.cover,
        width: double.infinity,
        filterQuality: FilterQuality.high,
        loadingBuilder: (c, ch, pr) {
          if (pr == null) return ch;
          return Container(
            height: 180,
            color: pnl2,
            child: const Center(child: CircularProgressIndicator(color: gold)),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: pnl2,
          child: const Icon(Icons.sports_soccer, color: gold, size: 60),
        ),
      ),
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
  final date = pDate(p);
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebPage(url: pLink(p), title: pTitle(p)),
      ),
    ),
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
                      filterQuality: FilterQuality.high,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, __) => Container(
                        color: pnl2,
                        child: const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: gold),
                          ),
                        ),
                      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pTitle(p),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: txtC, fontSize: 14, fontWeight: FontWeight.bold, height: 1.7),
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(date, style: const TextStyle(color: mutC, fontSize: 11)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _product(BuildContext context, dynamic p) {
  final img = (p['images'] as List?)?.isNotEmpty == true
      ? (p['images'][0]['src'] ?? '')
      : '';
  final name = p['name'] ?? '';
  final link = p['permalink'] ?? '';
  final inStock = p['stock_status'] == 'instock';
  final regularPrice = p['regular_price'] ?? '';
  final salePrice = p['sale_price'] ?? '';
  final isOnSale = salePrice.isNotEmpty && salePrice != regularPrice;

  return GestureDetector(
    onTap: () => openUrl(link),
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
              width: 125, height: 130,
              child: img.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, __) => Container(
                        color: pnl2,
                        child: const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: gold),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: pnl2,
                        child: const Icon(Icons.shopping_bag_outlined, color: gold, size: 40),
                      ),
                    )
                  : Container(
                      color: pnl2,
                      child: const Icon(Icons.shopping_bag_outlined, color: gold, size: 40),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: txtC, fontSize: 14, fontWeight: FontWeight.bold, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  if (isOnSale) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'تخفیف',
                            style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatPrice(regularPrice),
                          style: const TextStyle(
                            color: mutC,
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(salePrice),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (regularPrice.isNotEmpty) ...[
                    Text(
                      formatPrice(regularPrice),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'قیمت نامشخص',
                      style: TextStyle(color: mutC, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        inStock ? Icons.check_circle : Icons.cancel,
                        color: inStock ? Colors.green : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        inStock ? 'موجود' : 'ناموجود',
                        style: TextStyle(
                          color: inStock ? Colors.green : Colors.red,
                          fontSize: 11,
                        ),
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
        onTap: () => Navigator.push(
          c,
          MaterialPageRoute(builder: (_) => CategoryPostsPage(c: cats[i])),
        ),
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
