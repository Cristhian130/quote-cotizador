import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DraftNotificationCard extends StatelessWidget {
  final Map<String, dynamic> draft;
  final VoidCallback onTap;

  const DraftNotificationCard({
    super.key,
    required this.draft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = draft['name'] ?? 'Cliente sin nombre';
    final id = draft['id'] ?? 'Sin ID';
    final date = draft['date'] != null 
        ? DateTime.parse(draft['date'].toString()) 
        : DateTime.now();
    
    // Quick preview formatting
    final formattedDate = "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.user,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: $id • $formattedDate',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        color: Colors.white.withOpacity(0.3),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
