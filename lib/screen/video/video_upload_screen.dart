import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

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
    if (kIsWeb) {
      // ✅ 웹: nginx 프록시 기준 절대 URL
      return 'http://3.39.194.20:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    }
    if (Platform.isIOS) {
      return 'http://127.0.0.1:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  Future<void> _uploadFile(
    BuildContext context, {
    required String exercise,
    File? file,
    Uint8List? bytes,
    String? filename,
  }) async {
    final host = _baseUrl();
    final uri = Uri.parse('$host/ai/analyze');

    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['category'] = exercise;

    // 📌 웹은 fromBytes, 모바일은 fromPath
    if (kIsWeb && bytes != null && filename != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));
    } else if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('업로드 성공!')));
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('업로드 실패 (${resp.statusCode}) ${resp.body}'),
      ));
    }
  }

  Future<void> _pickAndUpload(BuildContext context, String exercise) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;

    if (kIsWeb) {
      final bytes = result.files.single.bytes;
      final filename = result.files.single.name;
      if (bytes != null) {
        await _uploadFile(context,
            exercise: exercise, bytes: bytes, filename: filename);
      }
    } else {
      final file = File(result.files.single.path!);
      await _uploadFile(context, exercise: exercise, file: file);
    }
  }

  Future<void> _openCameraRecorder(
      BuildContext context, String exercise) async {
    if (kIsWeb) {
      // ✅ 웹은 카메라 녹화 미지원
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('웹에서는 카메라 녹화가 지원되지 않습니다.')));
      return;
    }

    final File? recorded = await showModalBottomSheet<File?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => const _CameraRecorderSheet(),
    );
    if (recorded != null) {
      await _uploadFile(context, exercise: exercise, file: recorded);
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
              label: const Text('동영상 파일 업로드',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📷 카메라 녹화 (모바일 전용)
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
    _controller =
        CameraController(back, ResolutionPreset.medium, enableAudio: true);
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
                  child: Text('카메라 초기화 실패',
                      style: TextStyle(color: Colors.white)));
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
                          _isRecording
                              ? Icons.stop
                              : Icons.fiber_manual_record,
                          color: Colors.white),
                      label: Text(_isRecording ? '녹화 중지' : '녹화 시작',
                          style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording
                            ? Colors.redAccent
                            : Colors.green.shade600,
                        minimumSize: const Size(220, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
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
