import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos();
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final http.Client client;

  VideoRemoteDataSourceImpl(this.client);

  @override
  Future<List<VideoModel>> getVideos() async {
    final response = await client.get(
      Uri.parse(
        'https://backend-cj4o057m.fctl.app/bytes/scroll?page=1&limit=10',
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data']['data'];
      log(response.body);
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch videos');
    }
  }
}
