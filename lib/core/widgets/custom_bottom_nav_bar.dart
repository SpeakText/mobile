import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '즐겨찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.download), label: '다운로드'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
      ],
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.brown.withOpacity(0.5),
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
    );
  }
}
