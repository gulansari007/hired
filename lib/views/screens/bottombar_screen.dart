import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hired/views/home_screen.dart';
import 'package:hired/views/screens/connections_screen.dart';
import 'package:hired/views/screens/network_screen.dart';
import 'package:hired/views/screens/noticication_screen.dart';
import 'package:hired/views/screens/post_screen.dart';
import 'package:hired/views/screens/profile_screen.dart';

class BottombarScreen extends StatefulWidget {
  const BottombarScreen({super.key});

  @override
  State<BottombarScreen> createState() => _BottombarScreenState();
}

class _BottombarScreenState extends State<BottombarScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ConnectionsScreen(),
    const PostScreen(),
    const NoticicationScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    CupertinoIcons.house,
    CupertinoIcons.person_2,
    CupertinoIcons.plus_app,
    CupertinoIcons.bell,
    CupertinoIcons.person_circle,
  ];

  final List<IconData> _filledIcons = [
    CupertinoIcons.house_fill,
    CupertinoIcons.person_2_fill,
    CupertinoIcons.plus_app_fill,
    CupertinoIcons.bell_fill,
    CupertinoIcons.person_circle_fill,
  ];

  final List<String> _labels = [
    'Home',
    'My Network',
    'Post',
    'Notifications',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _animations =
        _animationControllers
            .map(
              (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: controller, curve: Curves.elasticOut),
              ),
            )
            .toList();

    // Animate the initial selected item
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      // Reset previous animation
      _animationControllers[_selectedIndex].reverse();

      setState(() {
        _selectedIndex = index;
      });

      // Animate new selection
      _animationControllers[index].forward();

      // Add haptic feedback for iOS feel
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_icons.length, (index) {
                final isSelected = _selectedIndex == index;
                final primaryColor = theme.primaryColor;

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animations[index].value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected
                                      ? _filledIcons[index]
                                      : _icons[index],
                                  color:
                                      isSelected
                                          ? primaryColor
                                          : isDark
                                          ? const Color(0xFF8E8E93)
                                          : const Color(0xFF6D6D70),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      isSelected
                                          ? primaryColor
                                          : isDark
                                          ? const Color(0xFF8E8E93)
                                          : const Color(0xFF6D6D70),
                                ),
                                child: Text(
                                  _labels[index],
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
