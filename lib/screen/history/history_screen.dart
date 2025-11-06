import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../home/workout_list_screen.dart';
import 'package:body_log/util/token_helper.dart'; // ✅ TokenHelper 경로 확인 필요

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDay = DateTime.now();
  List<Map<String, dynamic>> allData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkoutData();
  }

  /// ✅ 실제 API 호출 (DB 운동 기록 가져오기)
  Future<void> fetchWorkoutData() async {
    try {
      final token = await TokenHelper.getToken();

      if (token == null || token.isEmpty) {
        debugPrint("⚠️ 로그인 토큰이 없습니다. 로그인 후 이용해주세요.");
        setState(() => isLoading = false);
        return;
      }

      // ⚙️ 실제 서버 주소로 교체
      final url = Uri.parse('/api/v1/workouts');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("🔥 현재 토큰: $token");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          allData = data.map((item) {
            final rawDate = item['ended_at'];
            DateTime parsedDate;

            if (rawDate == null || rawDate.toString().trim().isEmpty) {
              parsedDate = DateTime.now();
            } else {
              try {
                parsedDate = DateTime.parse(rawDate);
              } catch (_) {
                try {
                  parsedDate = DateFormat('yyyy.MM.dd').parse(rawDate);
                } catch (_) {
                  parsedDate = DateTime.now();
                }
              }
            }

            final date = DateFormat('yyyy.MM.dd').format(parsedDate);

            return {
              'date': date,
              'name': item['exercise_type'] ?? 'Unknown',
              'count': item['rep_count'] ?? 0,
              'calories': (item['calories'] ?? 0).toDouble(),
              'time': 10,
            };
          }).toList();

          isLoading = false;
        });

        debugPrint("✅ 운동 기록 ${allData.length}개 불러옴");
      } else {
        debugPrint("❌ 서버 오류: ${response.statusCode} ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("⚠️ 운동 데이터 불러오기 중 오류: $e");
      setState(() => isLoading = false);
    }
  }

  /// 날짜별 그룹화
  Map<String, List<Map<String, dynamic>>> groupDataByDate() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    final base = selectedDay;

    for (int i = 0; i < 7; i++) {
      final date =
          DateFormat('yyyy.MM.dd').format(base.subtract(Duration(days: i)));
      grouped[date] = [];
    }

    for (var item in allData) {
      String date = item['date'];
      if (grouped.containsKey(date)) {
        grouped[date]!.add(item);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = groupDataByDate();

    return Scaffold(
      backgroundColor: const Color(0xFF20221E),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Column(
              children: [
                // 상단 제목 + 캘린더 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '운동 히스토리',
                        style: TextStyle(
                          fontFamily: 'Gamwulchi',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
                        onPressed: () async {
                          DateTime tempSelectedDay = selectedDay;

                          await showDialog(
                            context: context,
                            builder: (_) => StatefulBuilder(
                              builder: (context, setModalState) {
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.all(12),
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: 450,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: TableCalendar(
                                            focusedDay: tempSelectedDay,
                                            firstDay: DateTime.utc(2020, 1, 1),
                                            lastDay: DateTime.utc(2030, 12, 31),
                                            selectedDayPredicate: (day) =>
                                                isSameDay(day, tempSelectedDay),
                                            onDaySelected: (day, _) {
                                              setModalState(() {
                                                tempSelectedDay = day;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(
                                                    () => selectedDay = tempSelectedDay);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('확인'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 운동 날짜 리스트
                Expanded(
                  child: ListView(
                    children: groupedData.entries.map((entry) {
                      String date = entry.key;
                      List<Map<String, dynamic>> exercises = entry.value;

                      return GestureDetector(
                        onTap: exercises.isNotEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkoutListScreen(
                                      date: date,
                                      workouts: exercises,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEAEA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exercises.isNotEmpty
                                          ? '운동 개수: ${exercises.length}개'
                                          : '쉬어가는 날 😌',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final current = ModalRoute.of(context)?.settings.name;

          if (index == 0 && current != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && current != '/video_upload') {
            Navigator.pushNamed(context, '/video_upload');
          } else if (index == 2 && current != '/history') {
            Navigator.pushNamed(context, '/history');
          } else if (index == 3 && current != '/settings') {
            Navigator.pushNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: '영상'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}