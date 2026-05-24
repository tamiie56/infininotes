import 'label_model.dart';

class ChecklistItem {
  final String text;
  bool isChecked;

  ChecklistItem({required this.text, this.isChecked = false});

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      text: json['text'],
      isChecked: json['isChecked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'isChecked': isChecked};
  }
}

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String color;
  final bool isPinned;
  final bool isArchived;
  final bool isTrashed;
  final bool isCheckList;
  final List<LabelModel> labels;
  final List<ChecklistItem> checklist;
  final DateTime? reminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.isPinned,
    required this.isArchived,
    required this.isTrashed,
    required this.isCheckList,
    required this.labels,
    required this.checklist,
    this.reminder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      color: json['color'] ?? '#ffffff',
      isPinned: json['isPinned'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isTrashed: json['isTrashed'] ?? false,
      isCheckList: json['isCheckList'] ?? false,
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => LabelModel.fromJson(e))
              .toList() ??
          [],
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e))
              .toList() ??
          [],
      reminder: json['reminder'] != null
          ? DateTime.parse(json['reminder'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'isTrashed': isTrashed,
      'isCheckList': isCheckList,
      'labels': labels.map((e) => e.id).toList(),
      'checklist': checklist.map((e) => e.toJson()).toList(),
      'reminder': reminder?.toIso8601String(),
    };
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? color,
    bool? isPinned,
    bool? isArchived,
    bool? isTrashed,
    bool? isCheckList,
    List<LabelModel>? labels,
    List<ChecklistItem>? checklist,
    DateTime? reminder,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isTrashed: isTrashed ?? this.isTrashed,
      isCheckList: isCheckList ?? this.isCheckList,
      labels: labels ?? this.labels,
      checklist: checklist ?? this.checklist,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}