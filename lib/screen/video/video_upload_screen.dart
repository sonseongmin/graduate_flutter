import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'video_analysis_screen.dart';

class VideoUploadScreen extends StatelessWidget {
  final String? exerciseName;
  const VideoUploadScreen({super.key, this.exerciseName = '스쿼트'});

  String _resolveExerciseName(BuildContext context) {
    String effective = exerciseName ?? '스쿼트';
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['exerciseName'] is String && (args['exerciseName'] as String).isNotEmpty) {
      effective = args['exerciseName'] as String;
    }
    return effective;
  }
  String _baseHost() {
    if (kIsWeb) {
    // ✅ 웹: nginx 프록시 기준 → /api, /ai 같은 상대경로 사용
      return '';
    }

    if (Platform.isAndroid) {
    // ✅ 안드로이드 에뮬레이터에서 호스트 접근
      return '10.0.2.2';
    }

    if (Platform.isIOS) {
    // ✅ iOS 시뮬레이터
      return '127.0.0.1';
    }

    // ✅ 기타(데스크탑 실행 등)
    return '127.0.0.1';
  }

  Future<void> _uploadFile(BuildContext context, File videoFile, String exercise) async {
    final host = _baseHost();
    final uri = Uri.parse('/ai/analyze');

    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['category'] = exercise;
    request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      if (!context.mounted) return;

      // 업로드 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업로드 성공!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoAnalysisScreen(
            videoFile: videoFile,
            exercise: exercise,
            count: 10,
            duration: '00:02',
            calories: 20,
            issues: const ['무릎이 너무 앞으로 나감'],
            goodForm: const ['좋은 자세 입니다'],
          ),
        ),
      );
    } else {
      final msg = '업로드 실패 (${resp.statusCode}) ${resp.body.isNotEmpty ? resp.body : ''}';
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
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

  @override
  Widget build(BuildContext context) {
    final exercise = _resolveExerciseName(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('영상 업로드 - $exercise')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openCameraRecorder(context, exercise),
              icon: const Icon(Icons.videocam, color: Colors.white),
              label: const Text('실시간 촬영', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickAndUpload(context, exercise),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text('동영상 파일 업로드', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (index == 0 && currentRoute != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && currentRoute != '/exercise_category') {   // ← 고정
            Navigator.pushNamed(context, '/exercise_category');
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
              return const Center(child: Text('카메라 초기화 실패', style: TextStyle(color: Colors.white)));
            }
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller!)),
                Positioned(
                  left: 16, top: 16,
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
                      icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record, color: Colors.white),
                      label: Text(_isRecording ? '녹화 중지' : '녹화 시작', style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.redAccent : Colors.green.shade600,
                        minimumSize: const Size(220, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
