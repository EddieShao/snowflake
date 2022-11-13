import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:snowflake/theme.dart' as theme;
import 'package:snowflake/logic/snowflake.dart';

class SnowflakeWidget extends StatelessWidget {
    final ValueNotifier<bool> showNextSnowflakeEdges;
    final AnimationController spin;

    const SnowflakeWidget(this.showNextSnowflakeEdges, this.spin, {super.key});
    
    @override
    Widget build(BuildContext context) {
        final canvasSize = MediaQuery.of(context).size;

        return InteractiveViewer(
            maxScale: 2,
            minScale: 1,
            child: AnimatedBuilder(
                animation: spin,
                builder: (context, child) {
                    return Transform.rotate(
                        angle: -2 * math.pi * spin.value,
                        child: child,
                    );
                },
                child: Center(
                    child: Listener(
                        child: CustomPaint(
                            painter: _SnowflakePainter(showNextSnowflakeEdges),
                            size: Size.square(math.min(canvasSize.width, canvasSize.height) - 10),
                        )
                    ),
                ),
            ),
        );
    }
}

class _SnowflakePainter extends CustomPainter {
    final ValueNotifier<bool> showNextSnowflakeEdges;

    _SnowflakePainter(this.showNextSnowflakeEdges);

    @override
    void paint(Canvas canvas, Size size) {
        canvas.drawSnowflake(Snowflake().renderCurrent(size));
        if (showNextSnowflakeEdges.value) {
            canvas.drawNextSnowflakeEdges(Snowflake().renderNext(size));
        }
    }

    @override
    bool shouldRepaint(covariant _SnowflakePainter oldDelegate) =>
        showNextSnowflakeEdges.value != oldDelegate.showNextSnowflakeEdges.value;
}

extension SnowflakeDrawer on Canvas {
    void drawSnowflake(Render render) {
        Paint edgePaint = Paint()
            ..color = theme.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
        
        Paint nodePaint = Paint()
            ..color = theme.white
            ..strokeWidth = 0
            ..style = PaintingStyle.fill;

        for (var edge in render.edges) {
            drawLine(
                Offset(edge.first.x, edge.first.y),
                Offset(edge.second.x, edge.second.y),
                edgePaint
            );
        }

        for (var node in render.nodes) {
            drawCircle(Offset(node.x, node.y), 6, nodePaint);
        }
    }

    void drawNextSnowflakeEdges(Render render) {
        final paint = Paint()
            ..color = theme.white.withOpacity(0.2)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

        for (final edge in render.edges) {
            drawLine(
                Offset(edge.first.x, edge.first.y),
                Offset(edge.second.x, edge.second.y),
                paint
            );
        }
    }
}
