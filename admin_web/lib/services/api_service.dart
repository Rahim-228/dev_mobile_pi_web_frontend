import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static String? token;
  static String? _lastError;

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static String? get lastError => _lastError;

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        token = data['token'];
        return true;
      }
      _lastError = 'Invalid email or password';
      return false;
    } catch (e) {
      _lastError = 'Connection failed: $e';
      return false;
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Category.fromJson(e)).toList();
      }
    } catch (e) {
      _lastError = e.toString();
    }
    return [];
  }

  static Future<List<Place>> getPlaces({int? categoryId}) async {
    try {
      String url = '$baseUrl/places';
      if (categoryId != null) {
        url += '?category_id=$categoryId';
      }
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Place.fromJson(e)).toList();
      }
    } catch (e) {
      _lastError = e.toString();
    }
    return [];
  }

  static Future<Place?> createPlace(Place place, {Uint8List? imageBytes, String? imageName}) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/places');
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['category_id'] = place.categoryId.toString();
      request.fields['name_fr'] = place.nameFr;
      request.fields['name_ar'] = place.nameAr;
      request.fields['name_en'] = place.nameEn;
      if (place.descriptionFr != null) request.fields['description_fr'] = place.descriptionFr!;
      if (place.descriptionAr != null) request.fields['description_ar'] = place.descriptionAr!;
      if (place.descriptionEn != null) request.fields['description_en'] = place.descriptionEn!;
      if (place.googleMapsUrl != null) request.fields['google_maps_url'] = place.googleMapsUrl!;
      if (place.latitude != null) request.fields['latitude'] = place.latitude.toString();
      if (place.longitude != null) request.fields['longitude'] = place.longitude.toString();
      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName ?? 'image.jpg'));
      }
      final response = await request.send();
      if (response.statusCode == 201) {
        final body = await response.stream.bytesToString();
        return Place.fromJson(json.decode(body));
      }
      _lastError = 'Failed to create place (${response.statusCode})';
    } catch (e) {
      _lastError = e.toString();
    }
    return null;
  }

  static Future<Place?> updatePlace(int id, Place place, {Uint8List? imageBytes, String? imageName}) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/places/$id');
      final request = http.MultipartRequest('PUT', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['category_id'] = place.categoryId.toString();
      request.fields['name_fr'] = place.nameFr;
      request.fields['name_ar'] = place.nameAr;
      request.fields['name_en'] = place.nameEn;
      if (place.descriptionFr != null) request.fields['description_fr'] = place.descriptionFr!;
      if (place.descriptionAr != null) request.fields['description_ar'] = place.descriptionAr!;
      if (place.descriptionEn != null) request.fields['description_en'] = place.descriptionEn!;
      if (place.googleMapsUrl != null) request.fields['google_maps_url'] = place.googleMapsUrl!;
      if (place.latitude != null) request.fields['latitude'] = place.latitude.toString();
      if (place.longitude != null) request.fields['longitude'] = place.longitude.toString();
      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName ?? 'image.jpg'));
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        return Place.fromJson(json.decode(body));
      }
      _lastError = 'Failed to update place (${response.statusCode})';
    } catch (e) {
      _lastError = e.toString();
    }
    return null;
  }

  static Future<bool> deletePlace(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/places/$id'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }

  static Future<Category?> createCategory(Category category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/categories'),
        headers: _headers,
        body: json.encode(category.toJson()),
      );
      if (response.statusCode == 201) {
        return Category.fromJson(json.decode(response.body));
      }
      _lastError = 'Failed to create category';
    } catch (e) {
      _lastError = e.toString();
    }
    return null;
  }

  static Future<Category?> updateCategory(int id, Category category) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/categories/$id'),
        headers: _headers,
        body: json.encode(category.toJson()),
      );
      if (response.statusCode == 200) {
        return Category.fromJson(json.decode(response.body));
      }
      _lastError = 'Failed to update category';
    } catch (e) {
      _lastError = e.toString();
    }
    return null;
  }

  static Future<bool> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/categories/$id'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }
}
