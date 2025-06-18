import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ dotenv import
import 'package:youthbuk/reservation/alba_map_page.dart';
import 'firebase_options.dart';

// 페이지 임포트
import 'package:youthbuk/community/pages/poster_input_page.dart';
import 'package:youthbuk/home/home_page.dart';
import 'package:youthbuk/search/search_page.dart';
import 'package:youthbuk/reservation/reservation_page.dart';
import 'package:youthbuk/mypage/mypage_page.dart';
import 'package:youthbuk/member/login_page.dart';
import 'package:youthbuk/member/signup_page.dart';
import 'package:youthbuk/member/profile_signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode('ko');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(468.75, 1015),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YouthBuk',
          theme: ThemeData(primarySwatch: Colors.blue),
          routes: {
            '/login': (_) => const LoginPage(),
            '/signup': (_) => const SignupPage(),
            '/profileSetup': (_) {
              final user = FirebaseAuth.instance.currentUser;
              return user != null
                  ? ProfileSignupPage(user: user)
                  : const LoginPage();
            },
            '/main': (_) => const MainPage(),
            '/home': (_) => const HomePage(),
          },
          home:
              FirebaseAuth.instance.currentUser != null
                  ? const MainPage()
                  : const LoginPage(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    AlbaMapPage(),
    PosterInputPage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (idx) {
          if (idx == _currentIndex) return;
          setState(() => _currentIndex = idx);
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
