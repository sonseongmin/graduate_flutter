class WorkoutData {
  final String name;
  final int count;
  final int calories;
  final int time;
  final int accuracy;
  final List<String> issues;

  WorkoutData({
    required this.name,
    required this.count,
    required this.calories,
    required this.time,
    required this.accuracy,
    required this.issues,
  });
}