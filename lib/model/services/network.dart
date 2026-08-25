import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Network {
  static late Dio _dio;
  static final Network _instance = Network._internal();

  static Dio get dio => _dio;

  factory Network() => _instance;

  Network._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URI'] ?? 'http://182.213.27.207:60040',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'content-Type': 'application/json'},
      ),
    );
  }

  static void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
}
