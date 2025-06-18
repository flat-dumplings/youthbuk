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
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 6,
          ), // 화면과 살짝 띄우기
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final icons = [
                Icons.home,
                Icons.explore,
                Icons.calendar_today,
                Icons.chat_bubble,
                Icons.person,
              ];
              final outlines = [
                Icons.home_outlined,
                Icons.explore_outlined,
                Icons.calendar_today_outlined,
                Icons.chat_bubble_outline,
                Icons.person_outline,
              ];
              final labels = ['홈', '체험', '알바', '커뮤니티', '마이'];
              final isSelected = index == _currentIndex;

              return GestureDetector(
                onTap: () {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFFFA86A).withOpacity(0.15)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? icons[index] : outlines[index],
                        size: 24,
                        color:
                            isSelected
                                ? const Color(0xFFFFA86A)
                                : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? const Color(0xFFFFA86A)
                                : Colors.black45,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
