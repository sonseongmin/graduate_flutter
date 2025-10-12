import 'dart:async';
import 'dart:convert';
import 'dart:io' show File; // 모바일용
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:body_log/screen/home/today_workout_screen.dart';
import 'dart:html' as html; // 웹 파일 핸들링용

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

  /// ----------------------------
  ///  파일 업로드 (웹/모바일 통합)
  /// ----------------------------
  Future<void> _uploadFile(BuildContext context, dynamic fileInput, String exercise) async {
    final host = _baseHost();
    final uri = Uri.parse('$host/api/v1/exercise/analyze');

    final request = http.MultipartRequest('POST', uri);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    try {
      if (kIsWeb) {
        // 🌐 웹 전용 업로드
        if (fileInput is html.File) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(fileInput);
          await reader.onLoad.first;
          final bytes = reader.result as Uint8List;

          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileInput.name,
          ));
        } else {
          throw Exception('웹 파일 형식이 잘못되었습니다.');
        }
      } else {
        // 📱 모바일 업로드
        final file = fileInput as File;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      print('UPLOAD RESPONSE: ${resp.statusCode} - ${resp.body}');

      if (resp.statusCode == 202) {
        final data = jsonDecode(resp.body);
        final jobId = data['job_id'];
        if (jobId == null || jobId.toString().isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('job_id가 없습니다. 다시 시도해주세요.')),
          );
          return;
        }

        if (!context.mounted) return;
        _showProgressDialog(context);
        await _pollJobUntilDone(
          context,
          jobId,
          exercise,
          localFile: kIsWeb ? File('dummy') : fileInput,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: ${resp.statusCode} ${resp.body}')),
        );
      }
    } catch (e, s) {
      print('UPLOAD ERROR: $e');
      print(s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 중 오류 발생: $e')),
      );
    }
  }

  /// ----------------------------
  ///  파일 선택 & 업로드 (플랫폼별)
  /// ----------------------------
  Future<void> _pickAndUpload(BuildContext context, String exercise) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;

    if (kIsWeb) {
      // 🌐 웹: bytes 기반 html.File로 변환
      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;
      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일을 읽을 수 없습니다.')),
        );
        return;
      }

      final blob = html.Blob([fileBytes]);
      final file = html.File([blob], fileName);
      await _uploadFile(context, file, exercise);
    } else {
      // 📱 모바일
      final path = result.files.first.path;
      if (path == null) return;
      final file = File(path);
      await _uploadFile(context, file, exercise);
    }
  }

  Future<void> _openCameraRecorder(BuildContext context, String exercise) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('웹에서는 카메라 녹화를 지원하지 않습니다.')),
      );
      return;
    }
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

  // 운동명 로컬화
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
                  label: const Text('동영상 촬영',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
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
                  label: const Text('동영상 파일 업로드',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
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

  // ✅ 기존 폴링 로직 그대로 사용
  Future<void> _pollJobUntilDone(
      BuildContext context, String jobId, String exercise,
      {required File localFile}) async {
    final host = _baseHost();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    Timer? timer;
    bool finished = false;

    Future<void> closeDialogAnd(void Function() then) async {
      if (!finished) {
        finished = true;
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          then();
        }
      }
    }

    timer = Timer.periodic(const Duration(milliseconds: 900), (t) async {
      if (!context.mounted) return;
      final uri = Uri.parse('$host/api/v1/exercise/status/$jobId');
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

          final int count = (() {
            final v = result['rep_count'];
            if (v is num) return v.toInt();
            return int.tryParse('$v') ?? 0;
          })();

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

          final serverType = result['exercise_type']?.toString();
          final String displayName = _localizeExercise(serverType);

          try {
            const key = 'workout_records';
            final raw = prefs.getString(key);
            List<dynamic> list =
                (raw == null || raw.isEmpty) ? [] : (jsonDecode(raw) as List);
            list.add({
              'name': displayName,
              'count': count,
              'calories': calories,
              'accuracy': accuracy,
              'date': date,
            });
            await prefs.setString(key, jsonEncode(list));
          } catch (_) {}

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TodayWorkoutScreen(
                name: displayName,
                count: count,
                calories: calories,
                accuracy: accuracy,
                date: date,
              ),
            ),
          );
        });
      } else if (status == 'failed' || status == 'error') {
        timer?.cancel();
        final err = j['error']?.toString() ?? '알 수 없는 오류';
        await closeDialogAnd(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('분석 실패: $err')),
          );
        });
      }
    });

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

/// ----------------------------
///  카메라 녹화 BottomSheet
/// ----------------------------
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
                    style: TextStyle(color: Colors.white)),
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
                        backgroundColor: _isRecording
                            ? Colors.redAccent
                            : Colors.green.shade600,
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
