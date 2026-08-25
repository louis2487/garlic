import 'package:flutter/foundation.dart';
import 'package:garlic/model/services/garlic_service.dart';

class GarlicVM extends ChangeNotifier {
  final GarlicService _api = GarlicService();

  List<Map<String, dynamic>> parcels = [];
  List<Map<String, dynamic>> interviews = [];
  List<Map<String, dynamic>> mapParcels = [];
  bool loading = false;
  String? error;

  Future<void> loadParcels({String? q}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rows = await _api.listParcels(q: q);
      parcels = rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadBounds({
    required double minx,
    required double miny,
    required double maxx,
    required double maxy,
  }) async {
    try {
      final rows = await _api.getBoundsList(
        minx: minx,
        miny: miny,
        maxx: maxx,
        maxy: maxy,
      );
      mapParcels = rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadInterviews() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rows = await _api.listInterviews();
      interviews =
          rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getInterview(String uuid) =>
      _api.getInterview(uuid);

  Future<Map<String, dynamic>> saveInterview(Map<String, dynamic> body) async {
    final saved = await _api.updateInterview(body);
    await loadInterviews();
    return saved;
  }

  Future<Map<String, dynamic>?> getParcelSurvey({
    String? surveyUuid,
    String? parcelId,
  }) =>
      _api.getParcelSurvey(surveyUuid: surveyUuid, parcelId: parcelId);

  Future<Map<String, dynamic>?> getParcelDetail(String id) =>
      _api.getParcelDetail(id);

  Future<Map<String, dynamic>> saveParcelSurvey(
    Map<String, dynamic> body,
  ) async {
    final saved = await _api.updateParcelSurvey(body);
    await loadParcels();
    return saved;
  }

  Future<List<dynamic>> getParcelImg(String surveyUuid) =>
      _api.getParcelImg(surveyUuid);

  Future<List<dynamic>> uploadParcelImg({
    required String surveyUuid,
    required String slot,
    required String filePath,
  }) =>
      _api.uploadParcelImg(
        surveyUuid: surveyUuid,
        slot: slot,
        filePath: filePath,
      );
}
