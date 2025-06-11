// lib/member/signup_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_signup_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 이메일 입력
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return '유효한 이메일이 아닙니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 비밀번호 입력
                TextFormField(
                  controller: _pwCtrl,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  obscureText: _hidePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
                    if (v.length < 6) return '6자 이상 입력해주세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // 비밀번호 확인
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hideConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed:
                          () => setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                  obscureText: _hideConfirm,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '비밀번호를 다시 입력해주세요';
                    if (v != _pwCtrl.text) return '비밀번호가 일치하지 않습니다';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // 가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('가입하기'),
                  ),
                ),
                const SizedBox(height: 16),
                // 이미 계정이 있으면 뒤로 돌아가거나 로그인 화면으로
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('로그인 화면으로 돌아가기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text;
    setState(() => _isLoading = true);
    try {
      // FirebaseAuth 이메일/비밀번호 회원가입
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCred.user;
      if (user != null) {
        // 가입 성공: ProfileSignupPage로 이동, User 객체 전달
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileSignupPage(user: user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? '회원가입 중 오류가 발생했습니다';
      if (e.code == 'email-already-in-use') {
        msg = '이미 사용중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        msg = '유효하지 않은 이메일 형식입니다.';
      } else if (e.code == 'weak-password') {
        msg = '비밀번호는 6자 이상이어야 합니다.';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알 수 없는 오류: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
