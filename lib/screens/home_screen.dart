import 'package:flutter/material.dart';
import 'package:myapp/pages/feed_page.dart';
import 'package:myapp/pages/home_page.dart';

import 'package:myapp/pages/academy_page.dart';

import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/widgets/glass_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _animationController;
  late final Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with a simpler approach
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 20,
      ), // Longer duration for softer movement
    )..repeat(); // Simple repeat without reverse

    // Create a single alignment animation like in onboarding_screen
    _alignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, -1),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(1, -1),
          end: const Alignment(1, 1),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(1, 1),
          end: const Alignment(-1, 1),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-1, 1),
          end: const Alignment(-1, -1),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to build the radial gradient like in onboarding_screen
  Widget _buildRadialGradient(Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101010), // Base dark background
        gradient: RadialGradient(
          center: alignment,
          radius: 0.8,
          colors: [Colors.blue.shade700.withOpacity(0.7), Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Stack(
        children: [
          // Animated background gradient - simplified like onboarding_screen
          AnimatedBuilder(
            animation: _alignmentAnimation,
            builder: (context, child) {
              return _buildRadialGradient(_alignmentAnimation.value);
            },
          ),

          // Page content
          SafeArea(child: _buildCurrentPage()),

          // Bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return HomePage(userData: widget.userData);
      case 1:
        return const FeedPage();
      case 2:
        return const AcademyPage();

      case 3:
        return const ProfilePage();
      default:
        return HomePage(userData: widget.userData);
    }
  }
}
