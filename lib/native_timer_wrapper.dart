enum NativeTimerState { running, paused, expired }

class NativeTimerWrapper {
  final NativeTimerState state;

  final Duration total;

  final Duration elapsed;

  final DateTime stamp;

  NativeTimerWrapper(this.total, this.elapsed, this.stamp, this.state);

  Duration getDuration() => total;

  Duration getElapsed() => total != Duration.zero
      ? DateTime.now().difference(stamp) + elapsed
      : Duration.zero;

  Duration getRemaining() {
    final remaining = getDuration() - getElapsed();
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int getTimeStamp() => stamp.millisecondsSinceEpoch;

  NativeTimerWrapper increaseDuration(Duration increase) => isRunning()
      ? NativeTimerWrapper(
          total + increase,
          elapsed,
          stamp,
          NativeTimerState.running,
        )
      // Mirrors TimerService.addReceiver on Android: a non-running timer is
      // restarted fresh with just the added duration, not total + increase.
      : NativeTimerWrapper(
          increase,
          Duration.zero,
          DateTime.now(),
          NativeTimerState.running,
        );
  bool isRunning() => state == NativeTimerState.running;
  bool update() {
    if (state == NativeTimerState.running &&
        (getDuration() - getElapsed()).inMilliseconds <= 0) {
      state == NativeTimerState.expired;
    }
    return state != NativeTimerState.running;
  }

  static NativeTimerWrapper emptyTimer() => NativeTimerWrapper(
    Duration.zero,
    Duration.zero,
    DateTime.now(),
    NativeTimerState.expired,
  );
}

/// Rebuilds a running rest from the wall-clock time it should end.
///
/// [totalMs] is the original length. The stamp is [endsAt] minus that length,
/// so [NativeTimerWrapper.getRemaining] is the time left at [now].
NativeTimerWrapper? runningTimerFromDeadline({
  required DateTime? endsAt,
  required int? totalMs,
  DateTime? now,
}) {
  if (endsAt == null || totalMs == null || totalMs <= 0) return null;
  final clock = now ?? DateTime.now();
  if (!endsAt.isAfter(clock)) return null;
  final total = Duration(milliseconds: totalMs);
  return NativeTimerWrapper(
    total,
    Duration.zero,
    endsAt.subtract(total),
    NativeTimerState.running,
  );
}
