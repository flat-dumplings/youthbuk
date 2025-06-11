// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youthbuk/community/community_page.dart';
import 'package:youthbuk/mypage/mypage_page.dart';
import 'package:youthbuk/reservation/reservation_page.dart';
import 'package:youthbuk/search/search_page.dart';
import 'firebase_options.dart';

// 탭별 페이지들. 실제로는 별도 파일에 분리 가능.
import 'package:youthbuk/home/home_page.dart';

// 로그인/회원가입 페이지
import 'member/login_page.dart';
import 'member/signup_page.dart';
import 'member/profile_signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode('ko');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouthBuk',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/profileSetup': (_) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return ProfileSignupPage(user: user);
          } else {
            return const LoginPage();
          }
        },
        // 필요하다면 하단바 고정 화면으로 진입하는 경로도 추가
        '/main': (_) => const MainPage(),
        '/home': (_) => const HomePage(), // 여기에 추가
      },
      // 이미 로그인 상태라면 MainPage로, 아니라면 LoginPage로 보낼 수 있음
      home:
          FirebaseAuth.instance.currentUser != null
              ? const MainPage()
              : const LoginPage(),
    );
  }
}

// 탭 전환을 담당하는 메인 스캐폴드
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // 탭별 페이지 위젯 리스트. 필요하면 각 위젯 내부에서 추가 네비게이터를 둘 수도 있음.
  final List<Widget> _pages = const [
    HomePage(), // '/home' 과 중복이니, HomePage 내부 로직만 두고 route는 선택적으로 사용
    SearchPage(), // 새로 만들어야 할 탐색 화면
    ReservationPage(), // 예약 화면
    CommunityPage(), // 커뮤니티 화면
    MyPage(), // 마이(프로필) 화면
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 아이콘이 4~5개일 때 고정
        currentIndex: _currentIndex,
        onTap: (idx) {
          if (idx == _currentIndex) return;
          setState(() {
            _currentIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '탐색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '예약',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
