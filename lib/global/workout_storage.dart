import '../models/workout_data.dart';

Map<String, WorkoutData> workoutHistory = {
  '2025.07.12': WorkoutData(
    name: '스쿼트',
    count: 15,
    calories: 80,
    time: 10,
    accuracy: 60,
    issues: ['무릎이 너무 튀어나옴', '자세가 불안정함'],
  ),
  '2025.07.10': WorkoutData(
    name: '푸쉬업',
    count: 20,
    calories: 100,
    time: 12,
    accuracy: 85,
    issues: ['팔꿈치 각도 불안정'],
  ),
};