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
