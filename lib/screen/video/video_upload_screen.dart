import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:body_log/screen/home/today_workout_screen.dart';

class VideoUploadScreen extends StatelessWidget {
  final String? exerciseName;
  const VideoUploadScreen({super.key, this.exerciseName = '스쿼트'});

  String _resolveExerciseName(BuildContext context) {
    String effective = exerciseName ?? '스쿼트';
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map &&
        args['exerciseName'] is String &&
        (args['exerciseName'] as String).isNotEmpty) {
      effective = args['exerciseName'] as String;
    }
    return effective;
  }

  String _baseHost() {
    if (kIsWeb) return 'http://13.125.219.3';
    if (Platform.isAndroid) return 'http://10.0.2.2';
    return 'http://13.125.219.3';
  }

  Future<void> _uploadFile(BuildContext context, File videoFile, String exercise) async {
    final host = _baseHost();
    final uri = Uri.parse('/api/v1/exercise/analyze');

    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    // job_id 반환해야됨
    if (resp.statusCode == 202) {
      final body = resp.body.isNotEmpty ? resp.body : '{}';
      final data = jsonDecode(body) as Map<String, dynamic>;
      final jobId = data['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('job_id가 없습니다. 다시 시도해주세요.')),
        );
        return;
      }

      if (!context.mounted) return;
      _showProgressDialog(context);
      await _pollJobUntilDone(context, jobId, exercise, localFile: videoFile);
      return;
    }

    final msg = '분석 요청 실패 (${resp.statusCode}) ${resp.body.isNotEmpty ? resp.body : ''}';
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickAndUpload(BuildContext context, String exercise) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    await _uploadFile(context, file, exercise);
  }

  Future<void> _openCameraRecorder(BuildContext context, String exercise) async {
    final File? recorded = await showModalBottomSheet<File?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => const _CameraRecorderSheet(),
    );
    if (recorded != null) {
      await _uploadFile(context, recorded, exercise);
    }
  }

  // ===== [수정 2/3] 서버 코드 → 한글 운동명 변환 =====
  String _localizeExercise(String? code) {
    switch ((code ?? '').toLowerCase()) {
      case 'squat':
        return '스쿼트';
      case 'pullup':
        return '풀업';
      case 'pushup':
        return '푸쉬업';
      case 'jumpingjack':
        return '점핑잭';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _resolveExerciseName(context);

    return Scaffold(
      backgroundColor: const Color(0xFF20221E),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openCameraRecorder(context, exercise),
                  icon: const Icon(Icons.videocam, color: Colors.black),
                  label: const Text('동영상 촬영', style: TextStyle(color: Colors.black, fontSize: 20, )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAEAEA),
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickAndUpload(context, exercise),
                  icon: const Icon(Icons.upload_file, color: Colors.black),
                  label: const Text('동영상 파일 업로드', style: TextStyle(color: Colors.black, fontSize: 20, )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAEAEA),
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (index == 0 && currentRoute != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && currentRoute != '/video_upload') {
            Navigator.pushNamed(context, '/video_upload');
          } else if (index == 2 && currentRoute != '/history') {
            Navigator.pushNamed(context, '/history');
          } else if (index == 3 && currentRoute != '/settings') {
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

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.black87,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('분석 중입니다...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pollJobUntilDone(
      BuildContext context,
      String jobId,
      String exercise, {
        required File localFile,
      }) async {
    final host = _baseHost();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    Timer? timer;
    bool finished = false;

    Future<void> closeDialogAnd(void Function() then) async {
      if (!finished) {
        finished = true;
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // 로딩창 닫기
          then();
        }
      }
    }

    // 0.9초 간격 폴링
    timer = Timer.periodic(const Duration(milliseconds: 900), (t) async {
      if (!context.mounted) return;

      final uri = Uri.parse('/api/v1/exercise/status/$jobId');
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) {
        timer?.cancel();
        await closeDialogAnd(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('상태 조회 실패: ${res.statusCode}')),
          );
        });
        return;
      }

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final status = (j['status'] as String?) ?? 'queued';

      if (status == 'done') {
        timer?.cancel();
        final result = j['result'] as Map<String, dynamic>?;

        await closeDialogAnd(() async {
          if (result == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('결과가 비어있습니다.')),
            );
            return;
          }

          // ✅ 서버 결과 파싱 (count, calories, accuracy, date)
          final int count = (() {
            final v = result['rep_count'];
            if (v is num) return v.toInt();
            return int.tryParse('$v') ?? 0;
          })();

          // ===== [수정 3/3] 칼로리: 백엔드 실수값 반올림 후 정수로 =====
          final int calories = (() {
            final v = result['calories'];
            if (v is num) return v.round();
            final parsed = double.tryParse('$v');
            return parsed == null ? 0 : parsed.round();
          })();

          final int accuracy = (() {
            final v = result['accuracy'] ?? result['posture_accuracy'] ?? 0;
            if (v is num) return v.clamp(0, 100).toInt();
            return (int.tryParse('$v') ?? 0).clamp(0, 100);
          })();

          final String date = (() {
            final server = result['date']?.toString();
            if (server != null && server.isNotEmpty) return server;
            final now = DateTime.now();
            final mm = now.month.toString().padLeft(2, '0');
            final dd = now.day.toString().padLeft(2, '0');
            return '${now.year}-$mm-$dd';
          })();

          // ===== [수정 2/3] 서버 exercise_type → 한글 표시명으로 변환 =====
          final serverType = result['exercise_type']?.toString();
          final String displayName = _localizeExercise(serverType);

          // ✅ 기록 저장 (별도 모델 없이 바로 JSON 리스트에 append)
          try {
            const key = 'workout_records';
            final raw = prefs.getString(key);
            List<dynamic> list =
            (raw == null || raw.isEmpty) ? [] : (jsonDecode(raw) as List);
            // append
            list.add({
              'name': displayName,
              'count': count,
              'calories': calories,
              'accuracy': accuracy,
              'date': date,
            });
            await prefs.setString(key, jsonEncode(list));
          } catch (_) {
            // 저장 실패해도 화면 전환은 진행
          }

          // ✅ 분석 완료 후 TodayWorkoutScreen으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TodayWorkoutScreen(
                name: displayName,           // ← 한글 이름으로 전달
                count: count,
                calories: calories,          // ← 반올림된 정수
                accuracy: accuracy,
                date: date,
              ),
            ),
          );
        });
        // ===== [수정 1/3] 실패 상태 통합 처리: failed 또는 error 모두 처리 =====
      } else if (status == 'failed' || status == 'error') {
        timer?.cancel();
        final err = j['error']?.toString() ?? '알 수 없는 오류';
        await closeDialogAnd(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('분석 실패: $err')),
          );
        });
      } else {
        // 진행중/대기중 - 아무 것도 하지 않음
      }
    });

    // 타임아웃 (예: 2분)
    Future.delayed(const Duration(minutes: 2), () async {
      if ((timer?.isActive ?? false) && !finished) {
        timer?.cancel();
        await closeDialogAnd(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석이 지연되고 있습니다. 나중에 다시 시도해주세요.')),
          );
        });
      }
    });
  }
}

/// 카메라 녹화 BottomSheet
class _CameraRecorderSheet extends StatefulWidget {
  const _CameraRecorderSheet();

  @override
  State<_CameraRecorderSheet> createState() => _CameraRecorderSheetState();
}

class _CameraRecorderSheetState extends State<_CameraRecorderSheet> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(back, ResolutionPreset.medium, enableAudio: true);
    await _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_controller == null) return;
    if (!_isRecording) {
      await _controller!.prepareForVideoRecording();
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } else {
      final xfile = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      if (!mounted) return;
      Navigator.pop<File>(context, File(xfile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = MediaQuery.of(context).size;
    return SafeArea(
      child: SizedBox(
        height: view.height,
        child: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_controller == null || !_controller!.value.isInitialized) {
              return const Center(
                child: Text('카메라 초기화 실패', style: TextStyle(color: Colors.white)),
              );
            }
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller!)),
                Positioned(
                  left: 16,
                  top: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ElevatedButton.icon(
                      onPressed: _toggleRecord,
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.fiber_manual_record,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isRecording ? '녹화 중지' : '녹화 시작',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _isRecording ? Colors.redAccent : Colors.green.shade600,
                        minimumSize: const Size(220, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}