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
