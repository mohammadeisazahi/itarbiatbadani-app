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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A3D62),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> openSite() async {
    final Uri url = Uri.parse(
      'https://itarbiatbadani.ir',
    );

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
            ),
          ),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
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

                  ],
                ),
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

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.sports,
                    color: Color(0xFF0A3D62),
                  ),
                  title: const Text(
                    'مطالب تخصصی تربیت بدنی و علوم ورزشی',
                  ),
                  trailing: const Icon(
                    Icons.arrow_back_ios,
                  ),
                  onTap: openSite,
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.menu_book,
                    color: Color(0xFF0A3D62),
                  ),
                  title: const Text(
                    'طرح درس‌ها و منابع آموزشی',
                  ),
                  trailing: const Icon(
                    Icons.arrow_back_ios,
                  ),
                  onTap: openSite,
                ),
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
              label: 'فروشگاه',
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
