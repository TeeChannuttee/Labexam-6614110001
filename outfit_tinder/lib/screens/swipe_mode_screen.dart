import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/look.dart';
import '../providers/look_provider.dart';

class SwipeModeScreen extends StatefulWidget {
  const SwipeModeScreen({super.key});

  @override
  State<SwipeModeScreen> createState() => _SwipeModeScreenState();
}

class _SwipeModeScreenState extends State<SwipeModeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _dragDistance = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(bool isLiked, List<Look> looks) {
    if (_currentIndex < looks.length) {
      final look = looks[_currentIndex];
      context.read<LookProvider>().swipeLook(look.id, isLiked);

      setState(() {
        _currentIndex++;
        _dragDistance = 0;
      });

      _animationController.forward().then((_) {
        _animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LookProvider>();
    final looks = provider.allLooks;
    final isDarkMode = provider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: looks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่มีลุคให้ปัด',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add'),
                    child: const Text('เพิ่มลุคใหม่'),
                  ),
                ],
              ),
            )
          : _currentIndex >= looks.length
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 100,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'ปัดครบทุกลุคแล้ว!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                        child: const Text('เริ่มใหม่'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('กลับไปหน้าหลัก'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Background cards (stack preview)
                    if (_currentIndex + 2 < looks.length)
                      _buildBackgroundCard(looks[_currentIndex + 2], isDarkMode, 2),
                    if (_currentIndex + 1 < looks.length)
                      _buildBackgroundCard(looks[_currentIndex + 1], isDarkMode, 1),
                    
                    // Current card
                    _buildSwipeCard(looks[_currentIndex], isDarkMode),
                    
                    // Swipe indicators
                    if (_dragDistance != 0) _buildSwipeIndicators(),
                  ],
                ),
    );
  }

  Widget _buildBackgroundCard(Look look, bool isDarkMode, int depth) {
    return Center(
      child: Transform.scale(
        scale: 1 - (depth * 0.05),
        child: Transform.translate(
          offset: Offset(0, depth * 10.0),
          child: Opacity(
            opacity: 1 - (depth * 0.2),
            child: Container(
              width: 350,
              height: 500,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeCard(Look look, bool isDarkMode) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragDistance += details.delta.dx;
        });
      },
      onPanEnd: (details) {
        if (_dragDistance.abs() > 100) {
          _handleSwipe(_dragDistance > 0, context.read<LookProvider>().allLooks);
        } else {
          setState(() {
            _dragDistance = 0;
          });
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: _dragDistance, end: _dragDistance),
        duration: const Duration(milliseconds: 100),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: Transform.rotate(
              angle: value * 0.001,
              child: child,
            ),
          );
        },
        child: Center(
          child: Container(
            width: 350,
            height: 500,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: look.imageBytes != null
                        ? Image.memory(
                            look.imageBytes!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.checkroom,
                              size: 100,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),
                // Info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        look.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'สไตล์: ${look.style}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('ความมั่นใจ: '),
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < look.confidenceLevel
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 20,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left (No)
          if (_dragDistance < -20)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Opacity(
                opacity: min(1.0, (-_dragDistance / 100)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          // Right (Yes)
          if (_dragDistance > 20)
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Opacity(
                opacity: min(1.0, _dragDistance / 100),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
