import 'package:flutter/material.dart';
import '../../../data/models/note_model.dart';
import '../../../data/providers/note_provider.dart';
import '../../../core/utils/color_utils.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final bool isListView;
  final VoidCallback? onRefresh;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isListView = false,
    this.onRefresh,
  });

  String _formatReminder(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $hour:$min $period';
  }

  void _showContextMenu(BuildContext context, Color bgColor, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF2D2E30) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(
              note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            title: Text(note.isPinned ? 'Unpin' : 'Pin'),
            onTap: () async {
              Navigator.pop(context);
              await context.read<NoteProvider>().pinNote(note.id);
              onRefresh?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archive'),
            onTap: () async {
              Navigator.pop(context);
              await context.read<NoteProvider>().archiveNote(note.id);
              onRefresh?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outlined, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<NoteProvider>().trashNote(note.id);
              onRefresh?.call();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWhiteNote = note.color == '#ffffff';
    final bgColor = isDark && isWhiteNote
        ? const Color(0xFF3C3F43)
        : ColorUtils.fromHex(note.color);
    final textColor = ColorUtils.textColorFor(bgColor);
    final isColored = !isWhiteNote;

    final checkedCount = note.checklist.where((i) => i.isChecked).length;
    final totalCount = note.checklist.length;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context, bgColor, textColor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: isColored
              ? Border.all(
                  color: bgColor.withValues(alpha: 0.6),
                  width: 0.5,
                )
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.5,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isColored)
                Container(
                  height: 3,
                  color: textColor.withValues(alpha: 0.25),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.push_pin,
                              size: 13,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pinned',
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (note.title.isNotEmpty) ...[
                      Text(
                        note.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (note.isCheckList && totalCount > 0) ...[
                      ...note.checklist.take(4).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              children: [
                                Icon(
                                  item.isChecked
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 13,
                                  color: item.isChecked
                                      ? const Color(0xFF1A73E8)
                                      : textColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: item.isChecked
                                          ? textColor.withValues(alpha: 0.45)
                                          : textColor.withValues(alpha: 0.85),
                                      decoration: item.isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor:
                                          textColor.withValues(alpha: 0.4),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (totalCount > 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '+${totalCount - 4} more',
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      _ChecklistProgress(
                        checked: checkedCount,
                        total: totalCount,
                        textColor: textColor,
                      ),
                    ] else if (note.content.isNotEmpty)
                      Text(
                        note.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                        maxLines: isListView ? 3 : 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (note.reminder != null || note.labels.isNotEmpty)
                      const SizedBox(height: 8),
                    if (note.reminder != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.alarm,
                                size: 11,
                                color: Color(0xFF1A73E8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatReminder(note.reminder!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1A73E8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (note.labels.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.labels
                            .map((label) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: textColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: textColor.withValues(alpha: 0.12),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    label.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textColor.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistProgress extends StatelessWidget {
  final int checked;
  final int total;
  final Color textColor;

  const _ChecklistProgress({
    required this.checked,
    required this.total,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : checked / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: textColor.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF1A73E8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$checked / $total completed',
          style: TextStyle(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}