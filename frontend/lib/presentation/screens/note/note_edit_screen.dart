import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/label_model.dart';
import '../../../data/providers/note_provider.dart';
import '../../../data/providers/label_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/color_utils.dart';

class NoteEditScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _color = '#ffffff';
  bool _isPinned = false;
  bool _isCheckList = false;
  List<ChecklistItem> _checklist = [];
  List<LabelModel> _selectedLabels = [];
  DateTime? _reminder;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _color = widget.note!.color;
      _isPinned = widget.note!.isPinned;
      _isCheckList = widget.note!.isCheckList;
      _checklist = List.from(widget.note!.checklist);
      _selectedLabels = List.from(widget.note!.labels);
      _reminder = widget.note!.reminder;
    }
    _titleController.addListener(() => _hasChanges = true);
    _contentController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final noteProvider = context.read<NoteProvider>();
    final data = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'color': _color,
      'isPinned': _isPinned,
      'isCheckList': _isCheckList,
      'checklist': _checklist.map((e) => e.toJson()).toList(),
      'labels': _selectedLabels.map((e) => e.id).toList(),
      'reminder': _reminder?.toIso8601String(),
    };
    if (widget.note != null) {
      await noteProvider.updateNote(widget.note!.id, data);
    } else {
      await noteProvider.createNote(data);
    }
    if (mounted) Navigator.pop(context);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Note color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: AppConstants.noteColors.map((hex) {
                final color = ColorUtils.fromHex(hex);
                return GestureDetector(
                  onTap: () {
                    setState(() { _color = hex; _hasChanges = true; });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == hex ? Colors.blue : Colors.grey.shade300,
                        width: _color == hex ? 2 : 1,
                      ),
                    ),
                    child: _color == hex ? const Icon(Icons.check, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLabelPicker() {
    final labelProvider = context.read<LabelProvider>();
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Labels', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              ...labelProvider.labels.map((label) {
                final isSelected = _selectedLabels.any((l) => l.id == label.id);
                return CheckboxListTile(
                  title: Text(label.name),
                  value: isSelected,
                  onChanged: (val) {
                    setModalState(() {
                      if (val == true) {
                        _selectedLabels.add(label);
                      } else {
                        _selectedLabels.removeWhere((l) => l.id == label.id);
                      }
                    });
                    setState(() => _hasChanges = true);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminder ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminder ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _hasChanges = true;
    });
  }

  void _addChecklistItem() {
    setState(() {
      _checklist.add(ChecklistItem(text: ''));
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = ColorUtils.fromHex(_color);
    final textColor = ColorUtils.textColorFor(bgColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            if (_hasChanges) _save();
            else Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: textColor),
            onPressed: () => setState(() { _isPinned = !_isPinned; _hasChanges = true; }),
          ),
          if (widget.note != null)
            IconButton(
              icon: Icon(Icons.archive_outlined, color: textColor),
              onPressed: () async {
                await context.read<NoteProvider>().archiveNote(widget.note!.id);
                if (mounted) Navigator.pop(context);
              },
            ),
          IconButton(
            icon: Icon(Icons.save_outlined, color: textColor),
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  if (_isCheckList) ...[
                    ..._checklist.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Row(
                        children: [
                          Checkbox(
                            value: item.isChecked,
                            onChanged: (val) => setState(() {
                              _checklist[i] = ChecklistItem(text: item.text, isChecked: val ?? false);
                              _hasChanges = true;
                            }),
                          ),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: item.text),
                              style: TextStyle(
                                color: textColor,
                                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              ),
                              decoration: InputDecoration(
                                hintText: 'List item',
                                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                                border: InputBorder.none,
                                filled: false,
                              ),
                              onChanged: (val) {
                                _checklist[i] = ChecklistItem(text: val, isChecked: item.isChecked);
                                _hasChanges = true;
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 18, color: textColor.withOpacity(0.6)),
                            onPressed: () => setState(() { _checklist.removeAt(i); _hasChanges = true; }),
                          ),
                        ],
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addChecklistItem,
                      icon: Icon(Icons.add, color: textColor.withOpacity(0.7)),
                      label: Text('Add item', style: TextStyle(color: textColor.withOpacity(0.7))),
                    ),
                  ] else
                    TextField(
                      controller: _contentController,
                      style: TextStyle(fontSize: 16, color: textColor),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Note',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  if (_reminder != null)
                    GestureDetector(
                      onTap: _pickReminder,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.alarm, size: 14, color: textColor.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              '${_reminder!.day}/${_reminder!.month}/${_reminder!.year} ${_reminder!.hour}:${_reminder!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() { _reminder = null; _hasChanges = true; }),
                              child: Icon(Icons.close, size: 14, color: textColor.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_selectedLabels.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 4,
                        children: _selectedLabels.map((label) => Chip(
                          label: Text(label.name, style: TextStyle(fontSize: 12, color: textColor)),
                          backgroundColor: textColor.withOpacity(0.1),
                          deleteIcon: Icon(Icons.close, size: 14, color: textColor.withOpacity(0.7)),
                          onDeleted: () => setState(() {
                            _selectedLabels.removeWhere((l) => l.id == label.id);
                            _hasChanges = true;
                          }),
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_box_outlined, color: textColor.withOpacity(0.7)),
                  onPressed: () => setState(() { _isCheckList = !_isCheckList; _hasChanges = true; }),
                  tooltip: 'Toggle checklist',
                ),
                IconButton(
                  icon: Icon(Icons.palette_outlined, color: textColor.withOpacity(0.7)),
                  onPressed: _showColorPicker,
                  tooltip: 'Change color',
                ),
                IconButton(
                  icon: Icon(Icons.label_outlined, color: textColor.withOpacity(0.7)),
                  onPressed: _showLabelPicker,
                  tooltip: 'Labels',
                ),
                IconButton(
                  icon: Icon(Icons.alarm_add_outlined, color: textColor.withOpacity(0.7)),
                  onPressed: _pickReminder,
                  tooltip: 'Reminder',
                ),
                if (widget.note != null)
                  IconButton(
                    icon: Icon(Icons.delete_outlined, color: textColor.withOpacity(0.7)),
                    onPressed: () async {
                      await context.read<NoteProvider>().trashNote(widget.note!.id);
                      if (mounted) Navigator.pop(context);
                    },
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}