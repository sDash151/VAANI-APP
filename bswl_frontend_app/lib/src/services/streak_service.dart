import 'dart:async';

class StreakService {
  // Replace this with your real backend call
  Future<List<int>> fetchUserStreak(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Example: 30 days of streak data (replace with real API response)
    return [
      2,
      3,
      0,
      1,
      4,
      2,
      0,
      3,
      1,
      2,
      4,
      0,
      0,
      1,
      2,
      3,
      4,
      1,
      0,
      2,
      3,
      1,
      0,
      0,
      2,
      3,
      4,
      1,
      0,
      2
    ];
  }
}
