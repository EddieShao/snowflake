import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:snowflake/theme.dart' as theme;
import 'package:snowflake/logic/snowflake.dart';

class SnowflakeWidget extends StatefulWidget {
    const SnowflakeWidget({super.key});
    
    @override
    State<StatefulWidget> createState() => SnowflakeWidgetState();
}

class SnowflakeWidgetState extends State<SnowflakeWidget> with SingleTickerProviderStateMixin {
    late final AnimationController spin = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

    @override
    Widget build(BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        return SizedBox(
            width: size.width,
            height: size.height,
            child: AnimatedBuilder(
                animation: spin,
                builder: (context, child) {
                    return Transform.rotate(
                        angle: -2 * math.pi * spin.value,
                        child: child,
                    );
                },
                child: Center(
                    child: CustomPaint(
                        painter: const _SnowflakePainter(),
                        size: Size.square(size.width - 40)
                    ),
                ),
            )
        );
    }
}

class _SnowflakePainter extends CustomPainter {
    const _SnowflakePainter();

    @override
    void paint(Canvas canvas, Size size) {
        Paint nodePaint = Paint()
            ..color = theme.white
            ..strokeWidth = 0
            ..style = PaintingStyle.fill;

        Paint edgePaint = Paint()
            ..color = theme.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

        var sf = Snowflake();
        
        // TODO: remove when implemented user editing
        //  Hard code a snowflake to draw
        sf.add(0, 0, 0, 2);
        sf.add(0, 2, -1, 3);
        sf.add(-1, 3, -1, 5);
        sf.add(-1, 5, 0, 6);
        sf.add(0, 6, 1, 5);
        sf.add(0, 6, -1, 7);
        sf.add(0, 6, 1, 7);
        sf.add(0, 6, 0, 8);
        sf.add(0, 6, 0, 4);

        canvas.drawSnowflake(sf.render(size), nodePaint, edgePaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}

extension SnowflakeDrawer on Canvas {
    void drawSnowflake(Render render, Paint nodePaint, Paint edgePaint) {
        for (var node in render.nodes) {
            drawCircle(Offset(node.x, node.y), 4, nodePaint);
        }
        for (var edge in render.edges) {
            drawLine(
                Offset(edge.first.x, edge.first.y),
                Offset(edge.second.x, edge.second.y),
                edgePaint
            );
        }
    }
}
