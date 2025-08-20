import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../home/workout_list_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDay = DateTime.now();

  List<Map<String, dynamic>> allData = [];

  @override
  void initState() {
    super.initState();
    fetchWorkoutData(); // 로컬 더미 데이터 로드
  }

  void fetchWorkoutData() {
    // 추후 API 연동 시 여기에 HTTP 요청 추가
    allData = [
      {
        'date': '2025.07.18',
        'name': '스쿼트',
        'count': 20,
        'calories': 90,
        'time': 12,
        'accuracy': 0.75,
        'issues': []
      },
      {
        'date': '2025.07.20',
        'name': '푸쉬업',
        'count': 25,
        'calories': 100,
        'time': 15,
        'accuracy': 0.8,
        'issues': []
      },
      {
        'date': '2025.07.23',
        'name': '푸쉬업',
        'count': 30,
        'calories': 110,
        'time': 13,
        'accuracy': 0.85,
        'issues': []
      },
    ];
  }

  Map<String, List<Map<String, dynamic>>> groupDataByDate() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    final today = DateTime.now();

    // 최근 7일 날짜 초기화
    for (int i = 0; i < 7; i++) {
      final date = DateFormat('yyyy.MM.dd').format(today.subtract(Duration(days: i)));
      grouped[date] = [];
    }

    for (var item in allData) {
      String date = item['date'];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = groupDataByDate();

    return Scaffold(
      backgroundColor: const Color(0xFFAED9A5),
      body: Column(
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.green),
                  onPressed: () async {
                    DateTime tempSelectedDay = selectedDay;
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
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
                                  selectedDayPredicate: (day) => isSameDay(day, tempSelectedDay),
                                  onDaySelected: (day, _) {
                                    setState(() => tempSelectedDay = day);
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
                                      setState(() => selectedDay = tempSelectedDay);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('확인'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
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

                double averageAccuracy = exercises.isNotEmpty
                    ? exercises.map((e) => e['accuracy'] as double).fold(0.0, (prev, val) => prev + val) / exercises.length
                    : 0.0;

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
                      color: const Color(0xFFDFF0D8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(date,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(exercises.isNotEmpty
                                  ? '운동 개수: ${exercises.length}개'
                                  : '쉬어가는 날 😌'),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 30,
                          lineWidth: 8,
                          percent: exercises.isNotEmpty
                              ? averageAccuracy.clamp(0.0, 1.0)
                              : 0.0,
                          center: Text(exercises.isNotEmpty
                              ? '${(averageAccuracy * 100).toInt()}%'
                              : '0%'),
                          progressColor:
                          exercises.isNotEmpty ? Colors.green : Colors.grey,
                          backgroundColor: Colors.grey[300]!,
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
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final current = ModalRoute.of(context)?.settings.name;

          if (index == 0 && current != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && current != '/exercise_category') {
            Navigator.pushNamed(context, '/exercise_category');
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
