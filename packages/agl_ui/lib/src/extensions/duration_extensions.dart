extension AppDurationExtension on Duration {
  String toMediaDuration(Duration totalDuration) {
    final twoDigitMinutes = _twoDigits(inMinutes.remainder(60).abs());
    final twoDigitSeconds = _twoDigits(inSeconds.remainder(60).abs());
    final minsAndSeconds = '$twoDigitMinutes:$twoDigitSeconds';
    if (totalDuration >= const Duration(hours: 1)) {
      // both `this` and `totalDuration` need to show HH:mm:ss
      return '${_twoDigits(inHours)}:$minsAndSeconds';
    } else {
      // show only mm:ss
      return minsAndSeconds;
    }
  }

  double percentageOfProgress(Duration totalDuration) {
    return inSeconds / totalDuration.inSeconds;
  }

  String _twoDigits(int n) => '$n'.padLeft(2, '0');
}
