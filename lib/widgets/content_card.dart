import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content_model.dart';
import '../utils/constants.dart';

class ContentCard extends StatelessWidget {
  final ContentModel content;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ContentCard({
    Key? key,
    required this.content,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  }) : super(key: key);

  final bool showActions;

  @override
  Widget build(BuildContext context) {
    // Generate a pseudo-random color for the sidebar based on content id
    final colorIndex = content.id.hashCode % 4;
    final sidebarColors = [
      const Color(0xFFF79071), // Orange
      const Color(0xFF81D4FA), // Blue
      const Color(0xFFC5E1A5), // Green
      const Color(0xFFCE93D8), // Purple
    ];
    final sidebarColor = sidebarColors[colorIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Colorful Sidebar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: sidebarColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: InkWell(
                onTap: () {
                  // Optional: View full details
                },
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: lightTextColor,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Date and Actions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDateShort(content.createdAt.toDate()),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          if (isAdmin || showActions) ...[
                            const Spacer(),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz, color: lightTextColor),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  onEdit?.call();
                                } else if (value == 'delete') {
                                  onDelete?.call();
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day}\n${months[date.month - 1]}';
  }
}
