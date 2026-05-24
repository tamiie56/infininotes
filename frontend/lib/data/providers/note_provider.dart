import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<NoteModel> get pinnedNotes => _notes.where((n) => n.isPinned).toList();
  List<NoteModel> get unpinnedNotes => _notes.where((n) => !n.isPinned).toList();

  Future<void> fetchNotes({String? search, String? label, bool archived = false, bool trashed = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notes = await _noteService.getNotes(search: search, label: label, archived: archived, trashed: trashed);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createNote(Map<String, dynamic> data) async {
    try {
      final note = await _noteService.createNote(data);
      if (note != null) {
        _notes.insert(0, note);
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

  Future<bool> updateNote(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _noteService.updateNote(id, data);
      if (updated != null) {
        final index = _notes.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notes[index] = updated;
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

  Future<bool> deleteNote(String id) async {
    try {
      final success = await _noteService.deleteNote(id);
      if (success) {
        _notes.removeWhere((n) => n.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> pinNote(String id) async {
    await _noteService.pinNote(id);
    await fetchNotes();
  }

  Future<void> archiveNote(String id) async {
    await _noteService.archiveNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> trashNote(String id) async {
    await _noteService.trashNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}