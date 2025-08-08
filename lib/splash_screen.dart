import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'shared/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // 控制Logo旋转和缩放动画
  late AnimationController _logoAnimationController;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoScaleAnimation;

  // 控制文字渐变和移动动画
  late AnimationController _textAnimationController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  // 控制波浪加载动画
  late AnimationController _loadingAnimationController;
  final List<Animation<double>> _loadingDotAnimations = [];

  // 控制粒子效果
  late AnimationController _particleAnimationController;
  final List<ParticleModel> _particles = [];

  @override
  void initState() {
    super.initState();

    // 初始化Logo动画控制器
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoRotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 60.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // 初始化文字动画控制器
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // 初始化加载动画控制器
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 创建5个点的动画，每个点有不同的延迟
    for (int i = 0; i < 5; i++) {
      final Animation<double> dotAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0),
          weight: 50.0,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _loadingAnimationController,
          curve: Interval(
            i * 0.2, // 每个点的起始时间错开
            0.2 + i * 0.2, // 每个点的结束时间错开
            curve: Curves.easeInOut,
          ),
        ),
      );
      _loadingDotAnimations.add(dotAnimation);
    }

    // 初始化粒子动画控制器
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    // 创建20个随机粒子
    _createParticles();

    // 启动所有动画
    _logoAnimationController.forward();

    // 延迟启动文字动画
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textAnimationController.forward();
      }
    });

    // 延迟导航到主屏幕
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _createParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        ParticleModel(
          position: Offset(
            random.nextDouble() * 400 - 200,
            random.nextDouble() * 400 - 200,
          ),
          speed: 0.2 + random.nextDouble() * 0.6,
          theta: random.nextDouble() * 2 * math.pi,
          radius: 1 + random.nextDouble() * 3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _loadingAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景粒子效果
            AnimatedBuilder(
              animation: _particleAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: ParticlePainter(
                    particles: _particles,
                    animation: _particleAnimationController.value,
                  ),
                );
              },
            ),

            // 中心内容
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo动画
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotateAnimation.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // 文字动画
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: const Text(
                          'Florsovivexa',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 80),

                // 加载动画
                AnimatedBuilder(
                  animation: _loadingAnimationController,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => _buildLoadingDot(index),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.brandTeal,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandTeal.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Icon(
            Icons.coffee,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Transform.scale(
        scale: _loadingDotAnimations[index].value,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.brandTeal,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandTeal.withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 粒子模型
class ParticleModel {
  Offset position;
  double speed;
  double theta;
  double radius;

  ParticleModel({
    required this.position,
    required this.speed,
    required this.theta,
    required this.radius,
  });
}

// 粒子绘制器
class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final double animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // 计算粒子当前位置
      final progress = (animation * particle.speed) % 1.0;
      final distance = progress * 300; // 最大移动距离

      final dx = center.dx +
          particle.position.dx +
          distance * math.cos(particle.theta);
      final dy = center.dy +
          particle.position.dy +
          distance * math.sin(particle.theta);

      // 计算粒子透明度
      final opacity = (1.0 - progress) * 0.7;

      // 绘制粒子
      final paint = Paint()
        ..color = AppColors.brandTeal.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(dx, dy),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
