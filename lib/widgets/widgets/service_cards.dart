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
