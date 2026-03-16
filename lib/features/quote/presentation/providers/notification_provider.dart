import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationState {
  final int draftCount;
  final List<Map<String, dynamic>> drafts;

  NotificationState({
    this.draftCount = 0,
    this.drafts = const [],
  });

  NotificationState copyWith({
    int? draftCount,
    List<Map<String, dynamic>>? drafts,
  }) {
    return NotificationState(
      draftCount: draftCount ?? this.draftCount,
      drafts: drafts ?? this.drafts,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return NotificationState();
  }

  void addDraft(Map<String, dynamic> draft) {
    state = state.copyWith(
      draftCount: state.draftCount + 1,
      drafts: [...state.drafts, draft],
    );
  }

  void clearNotifications() {
    state = state.copyWith(draftCount: 0);
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});
