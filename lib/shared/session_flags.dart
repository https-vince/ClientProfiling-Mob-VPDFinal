/// Session-scoped flags that live only in memory.
/// Calling [reset] on logout clears them so next login starts fresh.
class SessionFlags {
  SessionFlags._();

  /// True once the Calendar drag-guide has been shown this session.
  static bool calendarDragGuideShown = false;

  /// Call on every logout to restore all flags to their initial state.
  static void reset() {
    calendarDragGuideShown = false;
  }
}
