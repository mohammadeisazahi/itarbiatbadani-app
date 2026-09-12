import 'package:flutter/material.dart';

import '../services/wordpress_api.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController controller =
      TextEditingController();

  List<dynamic> results = [];

  bool loading = false;

  Future<void> search() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final data =
          await WordPressApi.getPosts(
        search: text,
        perPage: 20,
      );

      setState(() {
        results = data;
      });
    } catch (_) {
      setState(() {
        results = [];
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff07131f),
      appBar: AppBar(
        backgroundColor:
            const Color(0xff0a3d62),
        title: const Text(
          'جستجو در مطالب',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction:
                  TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration:
                  InputDecoration(
                hintText:
                    'جستجوی مقاله...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    IconButton(
                  onPressed: search,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                ),
                filled: true,
                fillColor:
                    const Color(0xff0d2233),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          if (loading)
            const Padding(
              padding:
                  EdgeInsets.all(20),
              child:
                  CircularProgressIndicator(
                color: Color(0xfffbc531),
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: results.length,
              itemBuilder:
                  (context, index) {
                return PostCard(
                  post: results[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
