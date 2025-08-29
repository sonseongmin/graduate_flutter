import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InbodyScreen extends StatefulWidget {
  const InbodyScreen({super.key});

  @override
  State<InbodyScreen> createState() => _InbodyScreenState();
}

class _InbodyScreenState extends State<InbodyScreen> {
  final _formKey = GlobalKey<FormState>();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final muscleController = TextEditingController();
  final fatController = TextEditingController();
  final birthController = TextEditingController();
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    fetchInbodyData();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    muscleController.dispose();
    fatController.dispose();
    birthController.dispose();
    super.dispose();
  }

  Future<void> fetchInbodyData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('/api/v1/inbody'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      final apiSex = (data['sex'] as String?)?.toLowerCase();
      final apiBirth = data['birth_date']?.toString();

      setState(() {
        if (data['weight'] != null) {
          weightController.text = data['weight'].toString();
        }
        if (data['muscle_mass'] != null) {
          muscleController.text = data['muscle_mass'].toString();
        }
        if (data['body_fat'] != null) {
          fatController.text = data['body_fat'].toString();
        }
        if (data['height'] != null) {
          heightController.text = data['height'].toString();
        }

        if (apiSex == 'male') {
          selectedGender = '남';
        } else if (apiSex == 'female') {
          selectedGender = '여';
        } else {
          selectedGender = null;
        }

        birthController.text = (apiBirth != null && apiBirth.isNotEmpty)
            ? apiBirth.split('T').first
            : '';
      });

      // 값 있을 때만 저장, 없으면 제거
      if (selectedGender == null) {
        await prefs.remove('inbody_sex');
      } else {
        await prefs.setString('inbody_sex', selectedGender!);
      }

      if (birthController.text.trim().isEmpty) {
        await prefs.remove('inbody_birth');
      } else {
        await prefs.setString('inbody_birth', birthController.text.trim());
      }
    } else {
      // 조회 실패 시 이전 표시값 제거 (계정 전환/신규 사용자 보호)
      await prefs.remove('inbody_sex');
      await prefs.remove('inbody_birth');
      debugPrint('❌ 인바디 조회 실패: ${response.statusCode} - ${response.body}');
    }
  }

  String normalizeDate(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 8) {
      final year = cleaned.substring(0, 4);
      final month = cleaned.substring(4, 6);
      final day = cleaned.substring(6, 8);
      return '$year-$month-$day';
    }
    return input;
  }

  double? safeParse(String text) {
    return double.tryParse(text.trim());
  }

  Future<void> saveInbodyData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('성별을 선택해주세요.')),
      );
      return;
    }

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://3.39.194.20:3000/api/v1/inbody'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "height": safeParse(heightController.text),
        "weight": safeParse(weightController.text),
        "muscle_mass": safeParse(muscleController.text),
        "body_fat": safeParse(fatController.text),
        "sex": selectedGender == '남' ? 'male' : 'female',
        "birth_date": normalizeDate(birthController.text),
        "recorded_at": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      await prefs.setString('inbody_sex', selectedGender ?? '');
      await prefs.setString('inbody_birth', normalizeDate(birthController.text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 인바디 정보 저장 완료')),
      );
    } else {
      final error = utf8.decode(response.bodyBytes);
      debugPrint('❌ 저장 실패: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 저장 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('인바디 정보 입력'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('키 (cm)', heightController),
                _buildTextField('체중 (kg)', weightController),
                _buildTextField('골격근량 (kg)', muscleController),
                _buildTextField('체지방량 (kg)', fatController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        hint: const Text('선택하세요'),
                        decoration: const InputDecoration(labelText: '성별'),
                        items: ['남', '여'].map((gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        validator: (value) => value == null ? '성별을 선택해주세요' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: birthController,
                        decoration: const InputDecoration(
                          labelText: '생년월일',
                          hintText: '예: 1999-01-01',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '생년월일을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveInbodyData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '저장하기',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          final currentRoute = ModalRoute.of(context)?.settings.name;

          if (index == 0 && currentRoute != '/home') {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && currentRoute != '/exercise_category') {
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label 입력해주세요';
          }
          return null;
        },
      ),
    );
  }
}
