import 'package:flutter/material.dart';
import 'package:garlic/view/screens/interview_list_screen.dart';
import 'package:garlic/view/screens/parcel_list_screen.dart';
import 'package:garlic/view/screens/parcel_map_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/homeScreen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마늘·양파 현장조사')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '조사 모듈',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _ModuleTile(
            title: '면접조사',
            subtitle: '양식 5 · 표본 농가 면접',
            icon: Icons.people_alt_outlined,
            onTap: () =>
                Navigator.pushNamed(context, InterviewListScreen.routeName),
          ),
          const SizedBox(height: 12),
          _ModuleTile(
            title: '필지측정',
            subtitle: '양식 6 · 재배면적 실측',
            icon: Icons.map_outlined,
            onTap: () =>
                Navigator.pushNamed(context, ParcelListScreen.routeName),
          ),
          const SizedBox(height: 12),
          _ModuleTile(
            title: '필지 지도',
            subtitle: '남해 테스트 필지 지도에서 선택',
            icon: Icons.layers_outlined,
            onTap: () =>
                Navigator.pushNamed(context, ParcelMapScreen.routeName),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2F6B4F),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
