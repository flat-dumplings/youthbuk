import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youthbuk/community/pages/ai_page.dart';

import 'package:youthbuk/home/home_page.dart';
import 'package:youthbuk/search/search_page.dart';
import 'package:youthbuk/member/login_page.dart';
import 'package:youthbuk/member/signup_page.dart';
import 'package:youthbuk/member/profile_signup_page.dart';
import 'package:youthbuk/mypage/mypage_page.dart';
import 'package:youthbuk/reservation/alba_map_page.dart';

import 'firebase_options.dart';

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
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white, // 기본 배경색
            primaryColor: Colors.white, // 주 색상
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black, // 아이콘/텍스트 색
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // 버튼 색상 (원하면 흰색/주황 등 설정)
                foregroundColor: Colors.white, // 버튼 안 글자 색상
                shape: StadiumBorder(),
              ),
            ),
            useMaterial3: true,
          ),
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
  final Set<int>? initialSelectedFilterIndexes;
  final int? initialSearchTabIndex; // 추가

  const MainPage({
    super.key,
    this.initialIndex = 0,
    this.initialSelectedFilterIndexes,
    this.initialSearchTabIndex,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;
  Set<int> _selectedFilterIndexes = {0};
  int _searchPageInitialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _searchPageInitialTabIndex = widget.initialSearchTabIndex ?? 0;
    if (widget.initialSelectedFilterIndexes != null) {
      _selectedFilterIndexes = widget.initialSelectedFilterIndexes!;
      if (_currentIndex == 1) {
        _searchPageInitialTabIndex = 1; // 체험별 탭으로 강제 이동
      }
    }
  }

  void onCategorySelected(int categoryIndex) {
    setState(() {
      _selectedFilterIndexes = {categoryIndex};
      _currentIndex = 1;
      _searchPageInitialTabIndex = 1; // 체험별 탭으로 강제 이동
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(onCategorySelected: onCategorySelected),
          SearchPage(
            initialTabIndex: _searchPageInitialTabIndex,
            initialSelectedFilterIndexes: _selectedFilterIndexes,
            key: ValueKey(_searchPageInitialTabIndex), // 탭 인덱스 변경시 재빌드 유도
          ),
          AlbaMapPage(),
          AiPage(),
          MyPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
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
                Icons.add_a_photo_rounded,
                Icons.person,
              ];
              final outlines = [
                Icons.home_outlined,
                Icons.explore_outlined,
                Icons.calendar_today_outlined,
                Icons.add_a_photo_outlined,
                Icons.person_outline,
              ];
              final labels = ['홈', '체험', '알바', 'AI 생성', '마이'];
              final isSelected = index == _currentIndex;

              return GestureDetector(
                onTap: () {
                  if (_currentIndex != index) {
                    setState(() {
                      _currentIndex = index;
                      if (_currentIndex != 1) {
                        _selectedFilterIndexes = {0};
                        _searchPageInitialTabIndex = 0;
                      }
                    });
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
