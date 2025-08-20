import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoAnalysisScreen extends StatefulWidget {
  final File videoFile;
  final String exercise;
  final int count;
  final String duration;
  final int calories;
  final List<String> issues;
  final List<String> goodForm;

  const VideoAnalysisScreen({
    super.key,
    required this.videoFile,
    required this.exercise,
    required this.count,
    required this.duration,
    required this.calories,
    required this.issues,
    required this.goodForm,
  });

  @override
  _VideoAnalysisScreenState createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends State<VideoAnalysisScreen> {
  late VlcPlayerController _controller;
  String _dots = '.';
  late Future<void> _fetchAnalysis;

  @override
  void initState() {
    super.initState();
    // VLC 초기화 후 컨트롤러 설정
    _controller = VlcPlayerController.file(widget.videoFile,
        hwAcc: HwAcc.full, autoPlay: false, options: VlcPlayerOptions());
    _fetchAnalysis = _fetchAnalysisResult();

    // VLC 초기화 호출
    _initializeController();
  }

  // VLC 초기화 처리
  Future<void> _initializeController() async {
    try {
      await _controller.initialize();  // 초기화가 완료될 때까지 기다립니다.
      setState(() {});
    } catch (error) {
      // 오류가 발생한 경우 출력
      print("VLC 초기화 오류: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("VLC 초기화 오류: $error")),
      );
    }
  }

  Future<void> _fetchAnalysisResult() async {
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      widget.issues.add('어깨가 올라가 있음');
      widget.goodForm.add('좋은 자세 유지');
    });
  }

  void _updateDots() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_dots.length < 3) {
        setState(() {
          _dots = _dots + '.';
        });
      } else {
        setState(() {
          _dots = '.';
        });
      }
      _updateDots();
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateDots();

    return Scaffold(
      appBar: AppBar(title: Text('분석 결과')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영상 미리보기
            FutureBuilder(
              future: _controller.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Container(
                  height: 200,
                  child: VlcPlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                    virtualDisplay: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 분석 중 화면
            FutureBuilder<void>(
              future: _fetchAnalysis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.hourglass_empty, color: Colors.blue),
                      Text(' 분석 중 $_dots', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),
                      // 분석 중 상태로 횟수, 시간, 칼로리도 포함
                      Text('⏱ 분석 중 ${widget.duration}분'),
                      Text('${widget.exercise} ${widget.count}회'),
                      Text('🔥 분석 중 약 ${widget.calories} kcal'),
                    ],
                  );
                } else {
                  // 분석 완료
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.exercise} ${widget.count}회'),
                      Text('⏱ ${widget.duration}분'),
                      Text('🔥 약 ${widget.calories} kcal'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text('분석 결과', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // 실제 분석 결과 표시
                      ...widget.issues.map((e) => Row(
                        children: [
                          const Icon(Icons.close, color: Colors.red),
                          Text(' $e'),
                        ],
                      )),
                      ...widget.goodForm.map((e) => Row(
                        children: [
                          const Icon(Icons.check, color: Colors.green),
                          Text(' $e'),
                        ],
                      )),
                    ],
                  );
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('저장하기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
