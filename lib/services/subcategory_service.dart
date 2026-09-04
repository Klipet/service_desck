import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/subcategory_models/subcategory_create_model.dart';

class SubCategoryService {
  Future<List<SubCategoryCreateModel>> getAllSubCategories({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/SubCategory');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => SubCategoryCreateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки подкатегорий: ${response.statusCode}');
    }
  }

  Future<SubCategoryCreateModel> updateSubCategory({
    required String apiKey,
    required SubCategoryCreateModel subCategory,
  }) async {
    final uri = Uri.parse('$url/SubCategory/UpdateSubCategoryById')
        .replace(queryParameters: {'id': subCategory.oid.toString()});

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(subCategory.toJson()),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return subCategory;
      return SubCategoryCreateModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка обновления подкатегории: ${response.statusCode}');
    }
  }

  Future<SubCategoryCreateModel> createSubCategory({
    required String apiKey,
    required String name,
    required int categoryOid,
  }) async {
    final uri = Uri.parse('$url/SubCategory');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode({
        "name": name,
        "active": true,
        "categoryOid": categoryOid,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return SubCategoryCreateModel(name: name, categoryOid: categoryOid);
      }
      return SubCategoryCreateModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания подкатегории: ${response.statusCode}');
    }
  }
}
