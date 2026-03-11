import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NotePlusBackground extends StatelessWidget {
  final Widget child;
  final bool showDivider;

  const NotePlusBackground({
    Key? key,
    required this.child,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: mainGradient,
      ),
      child: Stack(
        children: [
          if (showDivider)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: WavyPainter(),
              ),
            ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class WavyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.4);
    
    path.quadraticBezierTo(
      size.width * 0.25, 
      size.height * 0.2, 
      size.width * 0.5, 
      size.height * 0.4
    );
    
    path.quadraticBezierTo(
      size.width * 0.75, 
      size.height * 0.6, 
      size.width, 
      size.height * 0.4
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
