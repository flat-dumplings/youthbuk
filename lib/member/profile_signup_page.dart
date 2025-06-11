// lib/member/profile_signup_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';
import 'services/user_repository.dart';
import 'login_page.dart';

class ProfileSignupPage extends StatefulWidget {
  final User user;
  const ProfileSignupPage({required this.user, super.key});

  @override
  State<ProfileSignupPage> createState() => _ProfileSignupPageState();
}

class _ProfileSignupPageState extends State<ProfileSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nicknameCtrl = TextEditingController();

  // 주소: 대한민국/기타 선택 후, 대한민국이면 시/도 드롭다운, 기타면 자유 입력
  String _addressCountry = '대한민국'; // '대한민국' 또는 '해외'
  String? _addressRegion; // 대한민국 시/도 선택값
  final TextEditingController _addressOtherCtrl = TextEditingController();

  // 전화번호: 국가 코드 선택 + 로컬 번호 입력
  Country _selectedCountry = Country.parse('KR'); // 기본: 대한민국
  final TextEditingController _phoneNumberCtrl = TextEditingController();
  // SMS 인증 관련
  final TextEditingController _smsCodeCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _codeSent = false;
  bool _isVerifyingCode = false;
  bool _isPhoneVerified = false;
  String? _verificationId;
  int? _resendToken;

  // UserRepository 인스턴스
  final UserRepository _userRepo = UserRepository();

  // 대한민국 시/도 리스트
  static const List<String> koreanRegions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  @override
  void initState() {
    super.initState();
    // 이미 Auth displayName이나 phoneNumber가 있으면 초기값 설정
    _nameCtrl.text = widget.user.displayName ?? '';
    if (widget.user.phoneNumber != null &&
        widget.user.phoneNumber!.isNotEmpty) {
      _isPhoneVerified = true;
      // widget.user.phoneNumber 은 이미 +82... 형태일 가능성이 높음
      // CountryPicker에서 국가 코드를 유추하기 어렵다면, 기본값 KR 두고 번호 비교
      _phoneNumberCtrl.text = widget.user.phoneNumber!;
      // 선택된 국가 코드 표시를 위해 CountryPicker에서 KR로 유지하거나,
      // 만약 다른 국가 인증으로 들어온 경우, 파싱 로직을 추가로 구현해야 함.
    }
    // 주소는 Firestore나 Auth에 저장된 값이 있으면 미리 채울 수 있지만,
    // 예시로는 빈 상태에서 시작
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _addressOtherCtrl.dispose();
    _phoneNumberCtrl.dispose();
    _smsCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로 가기: 로그아웃 후 로그인 화면으로
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 이름
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty) ? '이름을 입력해주세요' : null,
                ),
                const SizedBox(height: 16),
                // 닉네임
                TextFormField(
                  controller: _nicknameCtrl,
                  decoration: InputDecoration(
                    labelText: '닉네임',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? '닉네임을 입력해주세요'
                              : null,
                ),
                const SizedBox(height: 16),
                // 주소 선택: 국가
                Row(
                  children: [
                    const Text('국가:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _addressCountry,
                      items: const [
                        DropdownMenuItem(value: '대한민국', child: Text('대한민국')),
                        DropdownMenuItem(value: '해외', child: Text('해외')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _addressCountry = v!;
                          _addressRegion = null;
                          _addressOtherCtrl.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 주소 상세: 대한민국이면 시/도 드롭다운, 해외면 자유 입력
                if (_addressCountry == '대한민국') ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '시/도 선택',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _addressRegion,
                    items:
                        koreanRegions
                            .map(
                              (region) => DropdownMenuItem(
                                value: region,
                                child: Text(region),
                              ),
                            )
                            .toList(),
                    onChanged: (v) {
                      setState(() {
                        _addressRegion = v;
                      });
                    },
                    validator:
                        (v) => (v == null || v.isEmpty) ? '시/도를 선택해주세요' : null,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _addressOtherCtrl,
                    decoration: InputDecoration(
                      labelText: '주소 입력',
                      hintText: '거주 국가/도시 등을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return '주소를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // 전화번호 입력: 국가 코드 선택
                Row(
                  children: [
                    // CountryPicker를 이용해 국가 선택
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true, // 국가 코드 표시 (e.g. +82)
                            onSelect: (Country country) {
                              setState(() {
                                _selectedCountry = country;
                                // 전화번호 컨트롤러 초기화하지는 않음.
                                // 기존 입력값 보존하거나, 필요 시 비울 수 있음.
                              });
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 국가 플래그 이미지
                              Text(_selectedCountry.flagEmoji),
                              const SizedBox(width: 8),
                              Text('+${_selectedCountry.phoneCode}'),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 실제 로컬 번호 입력 (국가 코드를 제외한 부분)
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _phoneNumberCtrl,
                        decoration: InputDecoration(
                          labelText: '전화번호 (숫자만 입력)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        enabled: !_isPhoneVerified && !_codeSent,
                        validator: (v) {
                          if (_isPhoneVerified) return null;
                          if (v == null || v.trim().isEmpty) {
                            return '전화번호를 입력해주세요';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
                            return '숫자만 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 인증번호 받기 버튼
                if (!_isPhoneVerified && !_codeSent)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSendingCode ? null : _sendSmsCode,
                      child:
                          _isSendingCode
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('인증번호 받기'),
                    ),
                  ),
                // SMS 코드 입력 및 인증 확인 UI
                if (_codeSent && !_isPhoneVerified) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _smsCodeCtrl,
                    decoration: InputDecoration(
                      labelText: '인증번호 입력',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _isVerifyingCode ? null : _verifySmsCodeAndLink,
                      child:
                          _isVerifyingCode
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('인증 확인'),
                    ),
                  ),
                ],
                // 이미 인증된 경우 표시
                if (_isPhoneVerified) ...[
                  const SizedBox(height: 16),
                  Text(
                    '전화번호 인증 완료',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
                const SizedBox(height: 24),
                // 프로필 저장 버튼: 인증 완료되어야 활성화
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        (_isLoading || !_isPhoneVerified)
                            ? null
                            : _submitProfile,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('프로필 저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 국가 코드 + 로컬 번호를 합쳐서 국제전화 형식으로 반환
  String _getFullPhoneNumber() {
    final local = _phoneNumberCtrl.text.trim();
    // 예: selectedCountry.phoneCode='82', local='1012345678' → '+821012345678'
    return '+${_selectedCountry.phoneCode}$local';
  }

  Future<void> _sendSmsCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final fullPhone = _getFullPhoneNumber();

    setState(() {
      _isSendingCode = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 자동 인증: 즉시 링크
        try {
          await widget.user.linkWithCredential(credential);
          setState(() {
            _isPhoneVerified = true;
            _codeSent = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('자동 인증 완료되었습니다')));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('자동 인증 중 오류: $e')));
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('인증번호 전송 실패')));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _codeSent = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('인증번호가 전송되었습니다')));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      forceResendingToken: _resendToken,
    );

    setState(() {
      _isSendingCode = false;
    });
  }

  Future<void> _verifySmsCodeAndLink() async {
    final smsCode = _smsCodeCtrl.text.trim();
    if (_verificationId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('인증ID가 없습니다. 다시 시도해주세요')));
      }
      return;
    }
    if (smsCode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('인증번호를 입력해주세요')));
      }
      return;
    }

    setState(() {
      _isVerifyingCode = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await widget.user.linkWithCredential(credential);
      setState(() {
        _isPhoneVerified = true;
        _codeSent = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('전화번호 인증이 완료되었습니다')));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('인증 확인 실패')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  Future<void> _submitProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isPhoneVerified) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('전화번호 인증을 완료해주세요')));
      }
      return;
    }

    setState(() => _isLoading = true);

    final user = widget.user;
    final uid = user.uid;
    final name = _nameCtrl.text.trim();
    final nickname = _nicknameCtrl.text.trim();
    // 주소 조합
    String address;
    if (_addressCountry == '대한민국') {
      address = _addressRegion!; // 시/도
    } else {
      address = _addressOtherCtrl.text.trim();
    }
    final phoneFull = _getFullPhoneNumber();

    try {
      // 1) Auth displayName 업데이트
      if ((user.displayName ?? '') != name) {
        await user.updateDisplayName(name);
      }
      // 2) Firestore에 프로필 저장: UserRepository 사용
      final profile = UserProfile(
        uid: uid,
        name: name,
        nickname: nickname,
        address: address,
        phone: phoneFull,
        complete: null,
        inProgress: null,
        like: 0,
        point: 0,
        review: 0,
      );
      await _userRepo.createUserProfile(profile);
      // 3) 저장 성공: LoginPage로 이동
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필 저장 중 인증 오류')));
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필 저장 중 오류')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알 수 없는 오류')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
