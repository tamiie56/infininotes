import '../../../core/constants/api_constants.dart';
import '../models/note_model.dart';
import 'api_service.dart';

class NoteService {
  final ApiService _api = ApiService();

  Future<List<NoteModel>> getNotes({String? search, String? label, bool archived = false, bool trashed = false}) async {
    String url = ApiConstants.notes;
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (label != null) params['label'] = label;
    if (archived) params['archived'] = 'true';
    if (trashed) params['trashed'] = 'true';
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final response = await _api.get(url);
    if (response['success'] == true) {
      return (response['notes'] as List).map((e) => NoteModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<NoteModel?> createNote(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConstants.notes, data, auth: true);
    if (response['success'] == true) {
      return NoteModel.fromJson(response['note']);
    }
    return null;
  }

  Future<NoteModel?> updateNote(String id, Map<String, dynamic> data) async {
    final response = await _api.put('${ApiConstants.notes}/$id', data);
    if (response['success'] == true) {
      return NoteModel.fromJson(response['note']);
    }
    return null;
  }

  Future<bool> deleteNote(String id) async {
    final response = await _api.delete('${ApiConstants.notes}/$id');
    return response['success'] == true;
  }

  Future<bool> pinNote(String id) async {
    final response = await _api.patch('${ApiConstants.notes}/$id/pin');
    return response['success'] == true;
  }

  Future<bool> archiveNote(String id) async {
    final response = await _api.patch('${ApiConstants.notes}/$id/archive');
    return response['success'] == true;
  }

  Future<bool> trashNote(String id) async {
    final response = await _api.patch('${ApiConstants.notes}/$id/trash');
    return response['success'] == true;
  }
}