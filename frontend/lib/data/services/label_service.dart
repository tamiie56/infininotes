import '../../../core/constants/api_constants.dart';
import '../models/label_model.dart';
import 'api_service.dart';

class LabelService {
  final ApiService _api = ApiService();

  Future<List<LabelModel>> getLabels() async {
    final response = await _api.get(ApiConstants.labels);
    if (response['success'] == true) {
      return (response['labels'] as List).map((e) => LabelModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<LabelModel?> createLabel(String name) async {
    final response = await _api.post(ApiConstants.labels, {'name': name}, auth: true);
    if (response['success'] == true) {
      return LabelModel.fromJson(response['label']);
    }
    return null;
  }

  Future<LabelModel?> updateLabel(String id, String name) async {
    final response = await _api.put('${ApiConstants.labels}/$id', {'name': name});
    if (response['success'] == true) {
      return LabelModel.fromJson(response['label']);
    }
    return null;
  }

  Future<bool> deleteLabel(String id) async {
    final response = await _api.delete('${ApiConstants.labels}/$id');
    return response['success'] == true;
  }
}