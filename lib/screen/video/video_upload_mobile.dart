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

  String _baseUrl() {
    if (kIsWeb) return 'http://3.39.194.20:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    if (Platform.isIOS) return 'http://127.0.0.1:5000';
    return 'http://127.0.0.1:5000';
  }

  Future<void> _uploadFile(BuildContext context, File videoFile, String exercise) async {
    final uri = Uri.parse('${_baseUrl()}/api/v1/exercise/analyze');
    final request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 202) {
      final data = jsonDecode(resp.body);
      final jobId = data['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('job_id가 없습니다. 다시 시도해주세요.')),
        );
        return;
      }

      _showProgressDialog(context);
      await _pollJobUntilDone(context, jobId, exercise, localFile: videoFile);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('분석 요청 실패 (${resp.statusCode}) ${resp.body}')),
    );
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
                  label: const Text('동영상 촬영', style: TextStyle(color: Colors.black, fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAEAEA),
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickAndUpload(context, exercise),
                  icon: const Icon(Icons.upload_file, color: Colors.black),
                  label: const Text('동영상 파일 업로드', style: TextStyle(color: Colors.black, fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAEAEA),
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      BuildContext context, String jobId, String exercise,
      {required File localFile}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final uri = Uri.parse('${_baseUrl()}/api/v1/exercise/status/$jobId');
    bool finished = false;

    Timer.periodic(const Duration(seconds: 1), (t) async {
      final res = await http.get(uri, headers: token != null ? {'Authorization': 'Bearer $token'} : {});
      if (res.statusCode != 200) return;
      final j = jsonDecode(res.body);
      final status = j['status'];
      if (status == 'done') {
        t.cancel();
        finished = true;
        Navigator.of(context, rootNavigator: true).pop();
        final result = j['result'];
        final displayName = _localizeExercise(result['exercise_type']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TodayWorkoutScreen(
              name: displayName,
              count: (result['rep_count'] ?? 0).toInt(),
              calories: (result['calories'] ?? 0).round(),
              accuracy: ((result['accuracy'] ?? 0) as num).clamp(0, 100).toInt(),
              date: result['date'] ?? '',
            ),
          ),
        );
      }
    });

    Future.delayed(const Duration(minutes: 2), () {
      if (!finished && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석이 지연되고 있습니다.')),
        );
      }
    });
  }
}

class _CameraRecorderSheet extends StatefulWidget {
  const _CameraRecorderSheet();
  @override
  State<_CameraRecorderSheet> createState() => _CameraRecorderSheetState();
}

class _CameraRecorderSheetState extends State<_CameraRecorderSheet> {
  CameraController? _controller;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(back, ResolutionPreset.medium, enableAudio: true);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_controller == null) return;
    if (!_isRecording) {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } else {
      final xfile = await _controller!.stopVideoRecording();
      Navigator.pop<File>(context, File(xfile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: ElevatedButton.icon(
              onPressed: _toggleRecord,
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
              label: Text(_isRecording ? '녹화 중지' : '녹화 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Colors.green,
                minimumSize: const Size(200, 60),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
