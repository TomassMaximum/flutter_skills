import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_info.dart';

class PhotoRepository {
  static const String baseUrl =
      "https://weibaoping-skill-showcase.oss-cn-beijing.aliyuncs.com/";
  static const String photoManifestPath = "photo_manifest.json";

  Future<List<PhotoInfo>> fetchPhotoManifest() async {
    final response = await http.get(Uri.parse(baseUrl + photoManifestPath));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => PhotoInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photo manifest');
    }
  }
}
