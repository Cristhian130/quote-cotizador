import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/notification_provider.dart';
import '../molecules/draft_notification_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const NotificationPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final drafts = notificationState.drafts;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent background to close on tap outside
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          
          // The Panel
          Positioned(
            top: 70, // Below header
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 380,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header of panel
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Borradores Recientes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(
                                LucideIcons.x,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // List of cards
                      if (drafts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(LucideIcons.inbox, color: Colors.white24, size: 48),
                              SizedBox(height: 16),
                              Text(
                                'No hay borradores guardados',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: drafts.length,
                            itemBuilder: (context, index) {
                              final reversedIndex = drafts.length - 1 - index;
                              return DraftNotificationCard(
                                draft: drafts[reversedIndex],
                                onTap: () {
                                  // TODO: Load this draft into the state if needed
                                  onClose();
                                },
                              );
                            },
                          ),
                        ),
                        
                      // Bottom action
                      if (drafts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: TextButton(
                            onPressed: () {
                              ref.read(notificationProvider.notifier).clearNotifications();
                              onClose();
                            },
                            child: const Text(
                              'Limpiar todo',
                              style: TextStyle(color: Colors.orange, fontSize: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
