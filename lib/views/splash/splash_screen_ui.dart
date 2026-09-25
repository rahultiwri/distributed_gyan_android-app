import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreenUI extends StatelessWidget {
  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final Animation<Offset> logoSlide;

  final Animation<double> textFade;
  final Animation<Offset> textSlide;

  final AnimationController productController;
  final AnimationController milkController;
  final AnimationController footerController;

  const SplashScreenUI({
    super.key,
    required this.logoFade,
    required this.logoScale,
    required this.logoSlide,
    required this.textFade,
    required this.textSlide,
    required this.productController,
    required this.milkController,
    required this.footerController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ========================================================
        // SKY BLUE + GYAN PURPLE BACKGROUND
        // ========================================================

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE5F8FF),
              Color(0xFFDCF0FA),
              Color(0xFFC3E6F5),
              Color(0xFF0C447C),
            ],
            stops: [
              0.0,
              0.48,
              0.75,
              1.0,
            ],
          ),
        ),

        child: Stack(
          children: [
            // ====================================================
            // BACKGROUND GLOW
            // ====================================================

            Positioned(
              top: -size.width * 0.30,
              right: -size.width * 0.20,
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.30,
              left: -size.width * 0.30,
              child: Container(
                width: size.width * 0.60,
                height: size.width * 0.60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            // ====================================================
            // DECORATIVE DROPS
            // ====================================================

            Positioned(
              top: size.height * 0.12,
              left: size.width * 0.12,
              child: _drop(8),
            ),

            Positioned(
              top: size.height * 0.18,
              right: size.width * 0.12,
              child: _drop(6),
            ),

            Positioned(
              top: size.height * 0.34,
              left: size.width * 0.06,
              child: _drop(5),
            ),

            Positioned(
              top: size.height * 0.32,
              right: size.width * 0.07,
              child: _drop(9),
            ),

            // ====================================================
            // MAIN CONTENT
            // ====================================================

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ==================================================
                  // GYAN LOGO
                  // ==================================================

                  FadeTransition(
                    opacity: logoFade,
                    child: SlideTransition(
                      position: logoSlide,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: Container(
                          width: 250,
                          height: 185,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/Gyan_dairy_logo.png',
                            width: 230,
                            height: 175,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ==================================================
                  // GYAN DAIRY
                  // ==================================================

                  FadeTransition(
                    opacity: textFade,
                    child: SlideTransition(
                      position: textSlide,
                      child: const Text(
                        'Gyan Dairy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color:  Color(0xFF0C447C),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // ==================================================
                  // SEPARATOR
                  // ==================================================

                  FadeTransition(
                    opacity: textFade,
                    child: Container(
                      width: 48,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // HINDI TAGLINE
                  // ==================================================

                  FadeTransition(
                    opacity: textFade,
                    child: const Text(
                      'हर घूंट में शुद्धता',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF245D75),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // PRODUCT FLOW
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 155,
                    child: ClipRect(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          productController,
                          milkController,
                        ]),
                        builder: (context, child) {
                          return CustomPaint(
                            painter: ProductFlowPainter(
                              progress: productController.value,
                              milkProgress: milkController.value,
                            ),
                            child: _buildProducts(
                              size,
                              productController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ==================================================
                  // FOOTER
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 18,
                      bottom: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E93CE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                      ),
                    ),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: footerController,
                          builder: (context, child) {
                            return SizedBox(
                              width: 100,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: footerController.value,
                                  backgroundColor:
                                  Colors.white.withValues(alpha: 0.20),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Pure • Fresh • Trusted',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.90),
                            letterSpacing: 1.0,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // PRODUCTS
  // ==============================================================

  static const List<Map<String, dynamic>> _productList = [
    {
      'image': 'assets/images/milk.png',
      'y': 25.0,
      'size': 100.0,
    },
    {
      'image': 'assets/images/Dahi.png',
      'y': 35.0,
      'size': 95.0,
    },
    {
      'image': 'assets/images/Lassi.png',
      'y': 18.0,
      'size': 105.0,
    },
    {
      'image': 'assets/images/paneer.png',
      'y': 35.0,
      'size': 95.0,
    },
    {
      'image': 'assets/images/cow.png',
      'y': 20.0,
      'size': 105.0,
    },
    {
      'image': 'assets/images/Butter.png',
      'y': 38.0,
      'size': 90.0,
    },
    {
      'image': 'assets/images/Ghee.png',
      'y': 30.0,
      'size': 95.0,
    },
    {
      'image': 'assets/images/toned.png',
      'y': 28.0,
      'size': 100.0,
    },
  ];

  static const double _productSpacing = 225.0;

  Widget _buildProducts(
      Size size,
      double progress,
      ) {
    final width = size.width;

    final setWidth =
        _productList.length * _productSpacing;

    final totalWidth =
        width + setWidth;

    final offset =
        progress * totalWidth;

    final children = <Widget>[];

    // Do sets banao taaki continuous loop dikhe
    for (int setIndex = 0; setIndex < 2; setIndex++) {
      for (int i = 0; i < _productList.length; i++) {
        final product = _productList[i];

        final x = width -
            offset +
            (setIndex * setWidth) +
            (i * _productSpacing);

        children.add(
          _product(
            product['image'] as String,
            x,
            product['y'] as double,
            product['size'] as double,
          ),
        );
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: children,
    );
  }

  // ==============================================================
  // SINGLE PRODUCT
  // ==============================================================

  Widget _product(
      String image,
      double x,
      double y,
      double imageSize,
      ) {
    return Positioned(
      left: x,
      top: y,
      child: IgnorePointer(
        child: Image.asset(
          image,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ==============================================================
  // DROP
  // ==============================================================

  Widget _drop(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.60),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.20),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PRODUCT FLOW PAINTER
// ==================================================================

class ProductFlowPainter extends CustomPainter {
  final double progress;
  final double milkProgress;

  ProductFlowPainter({
    required this.progress,
    required this.milkProgress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final centerY =
        size.height * 0.67;

    // ==============================================================
    // SOFT GLOW
    // ==============================================================

    final glowPaint = Paint()
      ..color =
      Colors.white.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        18,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width / 2,
          centerY,
        ),
        width: size.width * 0.90,
        height: 45,
      ),
      glowPaint,
    );

    // ==============================================================
    // CONNECTED MILK FLOW
    // ==============================================================

    final milkPaint = Paint()
      ..color =
      Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(
      -20,
      centerY,
    );

    for (
    double x = 0;
    x <= size.width + 20;
    x += 4
    ) {
      final wave = math.sin(
        (x / size.width) *
            math.pi *
            4 +
            milkProgress *
                math.pi *
                2,
      ) *
          6;

      path.lineTo(
        x,
        centerY + wave,
      );
    }

    canvas.drawPath(
      path,
      milkPaint,
    );

    // ==============================================================
    // SMALL FLOWING DOTS
    // ==============================================================

    final dotPaint = Paint()
      ..color =
      Colors.white.withValues(alpha: 0.75);

    for (int i = 0; i < 7; i++) {
      final x =
          ((i / 7) * size.width +
              milkProgress *
                  size.width) %
              size.width;

      final y = centerY +
          math.sin(
            i * 1.4 +
                milkProgress *
                    math.pi *
                    2,
          ) *
              15;

      canvas.drawCircle(
        Offset(x, y),
        2.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant ProductFlowPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.milkProgress != milkProgress;
  }
}