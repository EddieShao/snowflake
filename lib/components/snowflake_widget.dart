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
        final contextSize = MediaQuery.of(context).size;
        final canvasSize = Size.square(math.min(contextSize.width, contextSize.height) - 10);

        final current = Snowflake().renderCurrent(canvasSize);
        final next = Snowflake().renderNext(canvasSize);

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
                    child: GestureDetector(
                        // TODO: implement touch actions
                        child: CustomPaint(
                            painter: _SnowflakePainter(showNextSnowflakeEdges, current, next),
                            size: canvasSize,
                        )
                    ),
                ),
            ),
        );
    }
}

class _SnowflakePainter extends CustomPainter {
    final ValueNotifier<bool> showNextSnowflakeEdges;
    final Render current;
    final Render next;

    _SnowflakePainter(this.showNextSnowflakeEdges, this.current, this.next);

    @override
    void paint(Canvas canvas, Size size) {
        drawCurrent(current, canvas);
        if (showNextSnowflakeEdges.value) {
            drawNext(next, canvas);
        }
    }

    @override
    bool shouldRepaint(covariant _SnowflakePainter oldDelegate) =>
        showNextSnowflakeEdges.value != oldDelegate.showNextSnowflakeEdges.value;
    
    void drawCurrent(Render render, Canvas canvas) {
        Paint edgePaint = Paint()
            ..color = theme.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
        
        Paint nodePaint = Paint()
            ..color = theme.white
            ..strokeWidth = 0
            ..style = PaintingStyle.fill;

        for (var edge in render.edges) {
            canvas.drawLine(
                Offset(edge.first.x, edge.first.y),
                Offset(edge.second.x, edge.second.y),
                edgePaint
            );
        }

        for (var node in render.nodes) {
            canvas.drawCircle(Offset(node.x, node.y), 6, nodePaint);
        }
    }

    void drawNext(Render render, Canvas canvas) {
        final paint = Paint()
            ..color = theme.white.withOpacity(0.2)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

        for (final edge in render.edges) {
            canvas.drawLine(
                Offset(edge.first.x, edge.first.y),
                Offset(edge.second.x, edge.second.y),
                paint
            );
        }
    }
}
