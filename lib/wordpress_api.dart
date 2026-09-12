import 'dart:convert';

import 'package:http/http.dart' as http;

class WordPressApi {
  static const String siteUrl = 'https://itarbiatbadani.ir';

  static const String apiUrl =
      '$siteUrl/wp-json/wp/v2';

  static Future<List<dynamic>> getPosts({
    int page = 1,
    int perPage = 6,
    String? search,
    int? category,
  }) async {
    final Map<String, String> params = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      'orderby': 'date',
      'order': 'desc',
      '_embed': 'true',
    };

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (category != null) {
      params['categories'] = category.toString();
    }

    final uri = Uri.parse(
      '$apiUrl/posts',
    ).replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'خطا در دریافت مطالب: ${response.statusCode}',
    );
  }

  static Future<List<dynamic>> getCategories() async {
    final uri = Uri.parse(
      '$apiUrl/categories',
    ).replace(
      queryParameters: {
        'per_page': '100',
        'hide_empty': 'true',
        'orderby': 'name',
        'order': 'asc',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'خطا در دریافت دسته‌ها',
    );
  }

  static Future<List<dynamic>> getSubCategories(
    int parentId,
  ) async {
    final uri = Uri.parse(
      '$apiUrl/categories',
    ).replace(
      queryParameters: {
        'per_page': '100',
        'hide_empty': 'true',
        'parent': parentId.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'خطا در دریافت زیر دسته‌ها',
    );
  }
}
