import 'package:flutter/material.dart';
import '../../../data/models/note_model.dart';
import '../../../core/utils/color_utils.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final bool isListView;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWhiteNote = note.color == '#ffffff';
    final bgColor = isDark && isWhiteNote
        ? const Color(0xFF3C3F43)
        : ColorUtils.fromHex(note.color);
    final textColor = ColorUtils.textColorFor(bgColor);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.isPinned)
              Icon(
                Icons.push_pin,
                size: 16,
                color: textColor.withValues(alpha: 0.6),
              ),
            if (note.title.isNotEmpty) ...[
              Text(
                note.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            if (note.isCheckList)
              ...note.checklist.take(5).map((item) => Row(
                    children: [
                      Icon(
                        item.isChecked
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 14,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.8),
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ))
            else if (note.content.isNotEmpty)
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withValues(alpha: 0.8),
                ),
                maxLines: isListView ? 3 : 8,
                overflow: TextOverflow.ellipsis,
              ),
            if (note.reminder != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 12,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note.reminder!.day}/${note.reminder!.month}',
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (note.labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: note.labels
                    .map((label) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            label.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}