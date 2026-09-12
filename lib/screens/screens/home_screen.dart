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
