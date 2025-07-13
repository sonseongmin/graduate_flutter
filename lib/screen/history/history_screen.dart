import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../home/today_workout_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDay = DateTime.now();

  final List<Map<String, dynamic>> allData = [
    {
      'date': '2025.07.10',
      'name': '스쿼트',
      'count': 15,
      'calories': 80,
      'time': 10,
      'accuracy': 0.6
    },
    {
      'date': '2025.07.11',
      'name': '푸쉬업',
      'count': 20,
      'calories': 82,
      'time': 11,
      'accuracy': 0.65
    },
    {
      'date': '2025.07.12',
      'name': '런지',
      'count': 25,
      'calories': 84,
      'time': 12,
      'accuracy': 0.7
    },
    {
      'date': '2025.07.13',
      'name': '스쿼트',
      'count': 30,
      'calories': 86,
      'time': 13,
      'accuracy': 0.75
    },
  ];

  List<Map<String, dynamic>> getWeekData(DateTime baseDay) {
    final formatter = DateFormat('yyyy.MM.dd');
    return List.generate(7, (index) {
      final date = baseDay.add(Duration(days: index));
      final formatted = formatter.format(date);
      final found = allData.firstWhere(
            (item) => item['date'] == formatted,
        orElse: () => {'date': formatted, 'name': '쉬는 날 😊'},
      );
      return found;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekData = getWeekData(selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFAED9A5),
      body: Column(
        children: [
          // 상단 제목과 캘린더 버튼
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TableCalendar(
                                  focusedDay: tempSelectedDay,
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  selectedDayPredicate: (day) =>
                                      isSameDay(day, tempSelectedDay),
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

          // 히스토리 리스트
          Expanded(
            child: ListView.builder(
              itemCount: weekData.length,
              itemBuilder: (context, index) {
                final item = weekData[index];
                final date = item['date'];
                final name = item['name'];
                final bool isRest = name == '쉬는 날 😊';

                return GestureDetector(
                  onTap: isRest
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TodayWorkoutScreen(
                          name: name,
                          count: item['count'],
                          calories: item['calories'],
                          time: item['time'],
                          accuracy: (item['accuracy'] * 100).toInt(),
                          date: date,
                          issues: const ['기록된 이슈 없음'],
                        ),
                      ),
                    );
                  },
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
                              Text(
                                date,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('운동: $name'),
                              if (!isRest) ...[
                                Text('횟수: ${item['count']}회'),
                                Row(
                                  children: [
                                    const Text('🔥 '),
                                    Text('${item['calories']} kcal'),
                                    const SizedBox(width: 12),
                                    const Text('⏱ '),
                                    Text('${item['time']}분'),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isRest)
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 8,
                            percent: item['accuracy'],
                            center: Text('${(item['accuracy'] * 100).toInt()}%'),
                            progressColor: Colors.green,
                            backgroundColor: Colors.grey[300]!,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 3) {
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
