import 'package:flutter/material.dart';
import 'package:warehouse_mobile/src/models/list_item.dart';
import 'package:warehouse_mobile/src/utils/constant.dart';

Widget buildDataCard({
  required BuildContext context,
  required String title,
  required List<ListItem> data,
  VoidCallback? onTap,
  List<ListItem>? resume,
}) {
  String firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';
  final Color circleAvatarForegroundColor = Theme.of(
    context,
  ).colorScheme.primary;
  final Color baseColor = Theme.of(context).colorScheme.primaryContainer;
  final Color circleAvatarBackgroundColor = baseColor.withValues(alpha: 0.3);
  final Color dividerColor = Theme.of(
    context,
  ).dividerColor.withValues(alpha: 0.5);
  final Color titleColor =
      Theme.of(context).textTheme.titleLarge?.color ??
      Theme.of(context).colorScheme.onSurface;
  final Color? itemTextColor = Theme.of(context).textTheme.bodyMedium?.color;

  return Card(
    elevation: 0.2,
    margin: const EdgeInsets.all(4.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      // side: BorderSide(color: Color(0xFFE9ECEF), width: 0.5),
    ),
    clipBehavior: Clip.antiAlias,
    // color: Theme.of(context).colorScheme.surface,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: circleAvatarBackgroundColor,
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: circleAvatarForegroundColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 12),
            ...data.asMap().entries.map((entry) {
              int index = entry.key;
              ListItem item = entry.value;
              Color itemColor = Constant
                  .metterGroupColors[index % Constant.metterGroupColors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: itemColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.libelle,
                        style: TextStyle(fontSize: 15, color: itemTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.value,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: itemTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),

            //add resume data if provided
            if (resume != null && resume.isNotEmpty) ...[

              const SizedBox(height: 10),
              Divider(height: 1, color: dividerColor),
              const SizedBox(height: 10),
              Text(
                Constant.userResume,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              ...resume.asMap().entries.map((entry) {
                int index = entry.key; // Index for resume items
                ListItem item = entry.value;
                Color itemColor =  Constant.pieChartColors[index % Constant.metterGroupColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),

                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: itemColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.libelle,
                          style: TextStyle(
                            fontSize: 15,
                            color: itemTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.value,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: itemTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    ),
  );
}
