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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A3D62),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String siteUrl = 'https://itarbiatbadani.ir';

  Future<void> openSite() async {
    final Uri url = Uri.parse(siteUrl);

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A3D62),
          title: const Text(
            'تربیت بدنی و علوم ورزشی',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0A3D62),
                      Color(0xFF3C6382),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'مرجع تخصصی',
                      style: TextStyle(
                        color: Color(0xFFFBC531),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'تربیت بدنی\nو علوم ورزشی',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'آخرین مطالب، آموزش‌ها و منابع تخصصی ورزش',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'دسته‌بندی‌ها',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [

                  'تربیت بدنی',
                  'علوم ورزشی',
                  'ورزش',
                  'طرح درس',
                  'آموزش',
                ]
                    .map(
                      (item) => Chip(
                        label: Text(item),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 25),

              const Text(
                'جدیدترین نوشته‌ها',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ArticleCard(
                title:
                    'جدیدترین مطالب تربیت بدنی و علوم ورزشی',
                onTap: openSite,
              ),

              ArticleCard(
                title:
                    'آموزش‌های تخصصی رشته تربیت بدنی',
                onTap: openSite,
              ),

              ArticleCard(
                title:
                    'طرح درس‌های ورزشی و منابع آموزشی',
                onTap: openSite,
              ),
            ],
          ),
        ),

        bottomNavigationBar: NavigationBar(
          destinations: const [

            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'خانه',
            ),

            NavigationDestination(
              icon: Icon(Icons.article),
              label: 'مطالب',
            ),

            NavigationDestination(
              icon: Icon(Icons.shopping_bag),
              label: 'محصولات',
            ),

            NavigationDestination(
              icon: Icon(Icons.menu),
              label: 'بیشتر',
            ),

          ],
        ),
      ),
    );
  }
}


class ArticleCard extends StatelessWidget {

  final String title;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(

        leading: const CircleAvatar(
          backgroundColor: Color(0xFF0A3D62),
          child: Icon(
            Icons.sports,
            color: Colors.white,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_back_ios,
        ),

        onTap: onTap,
      ),
    );
  }
}
