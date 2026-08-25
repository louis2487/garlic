import 'package:dio/dio.dart';
import 'package:garlic/model/services/network.dart';

class GarlicService {
  static final GarlicService _instance = GarlicService._internal();
  factory GarlicService() => _instance;
  GarlicService._internal();

  Dio get _dio => Network.dio;

  Future<List<dynamic>> listParcels({String? q}) async {
    final res = await _dio.get(
      '/v1/garlic/listParcels',
      queryParameters: q != null && q.isNotEmpty ? {'q': q} : null,
    );
    return res.data as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> getBoundsList({
    required double minx,
    required double miny,
    required double maxx,
    required double maxy,
  }) async {
    final res = await _dio.get(
      '/v1/garlic/getBoundsList',
      queryParameters: {
        'minx': minx,
        'miny': miny,
        'maxx': maxx,
        'maxy': maxy,
      },
    );
    return res.data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>?> getParcelDetail(String id) async {
    final res = await _dio.get(
      '/v1/garlic/getParcelDetail',
      queryParameters: {'id': id},
    );
    if (res.data == null || res.data == '') return null;
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<dynamic>> listInterviews() async {
    final res = await _dio.get('/v1/garlic/listInterviews');
    return res.data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>?> getInterview(String surveyUuid) async {
    final res = await _dio.get(
      '/v1/garlic/getInterview',
      queryParameters: {'survey_uuid': surveyUuid},
    );
    if (res.data == null || res.data == '') return null;
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateInterview(Map<String, dynamic> body) async {
    final res = await _dio.post('/v1/garlic/updateInterview', data: body);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>?> getParcelSurvey({
    String? surveyUuid,
    String? parcelId,
  }) async {
    final res = await _dio.get(
      '/v1/garlic/getParcelSurvey',
      queryParameters: {
        if (surveyUuid != null) 'survey_uuid': surveyUuid,
        if (parcelId != null) 'parcel_id': parcelId,
      },
    );
    if (res.data == null || res.data == '') return null;
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateParcelSurvey(
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post('/v1/garlic/updateParcelSurvey', data: body);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<dynamic>> getParcelImg(String surveyUuid) async {
    final res = await _dio.get(
      '/v1/garlic/getParcelImg',
      queryParameters: {'survey_uuid': surveyUuid},
    );
    return res.data as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> uploadParcelImg({
    required String surveyUuid,
    required String slot,
    required String filePath,
    String imgPath = 'uploads/garlic',
  }) async {
    final form = FormData.fromMap({
      'survey_uuid': surveyUuid,
      'slot': slot,
      'imgPath': imgPath,
      'files': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/v1/garlic/uploadParcelImg', data: form);
    return res.data as List<dynamic>? ?? [];
  }

  Future<void> deleteParcelImg(int id) async {
    await _dio.get(
      '/v1/garlic/deleteParcelImg',
      queryParameters: {'id': id},
    );
  }
}
