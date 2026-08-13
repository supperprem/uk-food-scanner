import 'package:flutter/material.dart';

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF43A047), width: 3),
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
        ),
        child: Stack(
          children: [
            // Corner accents
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 4),
                    left: BorderSide(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 4),
                    right: BorderSide(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 4),
                    left: BorderSide(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 4),
                    right: BorderSide(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
            // Animated green scanning line
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  top: _animation.value * 136 + 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF43A047).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
