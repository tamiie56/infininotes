import 'package:flutter/material.dart';
import '../models/label_model.dart';
import '../services/label_service.dart';

class LabelProvider extends ChangeNotifier {
  final LabelService _labelService = LabelService();

  List<LabelModel> _labels = [];
  bool _isLoading = false;
  String? _error;

  List<LabelModel> get labels => _labels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLabels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _labels = await _labelService.getLabels();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createLabel(String name) async {
    try {
      final label = await _labelService.createLabel(name);
      if (label != null) {
        _labels.add(label);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLabel(String id, String name) async {
    try {
      final updated = await _labelService.updateLabel(id, name);
      if (updated != null) {
        final index = _labels.indexWhere((l) => l.id == id);
        if (index != -1) {
          _labels[index] = updated;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLabel(String id) async {
    try {
      final success = await _labelService.deleteLabel(id);
      if (success) {
        _labels.removeWhere((l) => l.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}