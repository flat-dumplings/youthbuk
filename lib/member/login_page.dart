// lib/member/login_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/main.dart';
import 'package:youthbuk/member/profile_signup_page.dart';
import 'package:youthbuk/member/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 227),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 60.h),
                  Image.asset(
                    'assets/images/login_logo.png',
                    width: 300.w,
                    height: 300.h,
                  ),
                  SizedBox(height: 40.h),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, size: 24.sp),
                      hintText: '이메일 주소',
                      hintStyle: TextStyle(fontSize: 14.sp),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
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
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _pwCtrl,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, size: 24.sp),
                      hintText: '비밀번호',
                      hintStyle: TextStyle(fontSize: 14.sp),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20.sp,
                        ),
                        onPressed:
                            () =>
                                setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    obscureText: _hidePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
                      if (v.length < 6) return '6자 이상 입력해주세요';
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('로그인', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            ),
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '아이디 / 비밀번호 찾기',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color.fromARGB(101, 158, 158, 158)),
                  SizedBox(height: 12.h),
                  Text(
                    '간편 로그인',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: Image.asset(
                            'assets/icons/google.png',
                            color: null, // ✅ 흰색 이미지가 회색으로 변하는 문제 해결
                            fit: BoxFit.contain, // 옵션: 꽉 채우되 비율 유지
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: Image.asset(
                            'assets/icons/naver.png',
                            color: null, // ✅ 흰색 이미지가 회색으로 변하는 문제 해결
                            fit: BoxFit.contain, // 옵션: 꽉 채우되 비율 유지
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text;
    setState(() => _isLoading = true);

    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCred.user;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 0)),
          );
        } else {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => ProfileSignupPage(user: user)),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? '로그인 중 오류가 발생했습니다';
      if (e.code == 'user-not-found') {
        msg = '등록되지 않은 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        msg = '비밀번호가 틀렸습니다.';
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
