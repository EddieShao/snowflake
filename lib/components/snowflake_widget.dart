import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snowflake/app_state.dart';
import 'dart:math' as math;
import 'package:snowflake/theme.dart' as theme;
import 'package:snowflake/logic/snowflake.dart';

class SnowflakeWidget extends StatefulWidget {
    const SnowflakeWidget({super.key});
    
    @override
    State<StatefulWidget> createState() => _SnowflakeWidgetState();
}

class _SnowflakeWidgetState extends State<SnowflakeWidget> with SingleTickerProviderStateMixin {
    late final AnimationController spin = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

    @override
    void initState() {
        super.initState();

        // TODO: replace hard-coded stuff with DB access
        Snowflake()
            ..clear()
            ..add(0, 0, 0, 2, 0)
            ..add(0, 2, -1, 3, 0)
            ..add(-1, 3, -1, 5, 0)
            ..add(-1, 5, 0, 6, 0)
            ..add(0, 6, 1, 5, 0)
            ..add(0, 6, -1, 7, 0)
            ..add(0, 6, 1, 7, 0)
            ..add(0, 6, 0, 8, 0)
            ..add(0, 6, 0, 4, 0);
    }

    @override
    Widget build(BuildContext context) {
        final sf = Snowflake();

        final contextSize = MediaQuery.of(context).size;
        final canvasSize = Size.square(math.min(contextSize.width, contextSize.height) - 10);

        Render current() => sf.renderCurrent(canvasSize);
        Render next() => sf.renderNext(canvasSize);

        final body = Center(
            child: GestureDetector(
                // TODO: implement touch actions
                child: Consumer<EditState>(
                    builder: (context, editState, child) {
                        return CustomPaint(
                            painter: _SnowflakePainter(editState.value, current(), next()),
                            size: canvasSize,
                        );
                    },
                ),
            ),
        );

        return Consumer<DoneState>(
            builder: (context, doneState, child) {
                return InteractiveViewer(
                    maxScale: 2,
                    minScale: 1,
                    child: doneState.value ? _withSpin(body) : body,
                );
            },
        );
    }

    AnimatedBuilder _withSpin(Widget body) =>
        AnimatedBuilder(
            animation: spin,
            builder: (context, child) {
                return Transform.rotate(
                    angle: -2 * math.pi * spin.value,
                    child: child,
                );
            },
            child: body
        );
}

class _SnowflakePainter extends CustomPainter {
    final bool editing;
    final Render current;
    final Render next;

    _SnowflakePainter(this.editing, this.current, this.next);

    @override
    void paint(Canvas canvas, Size size) {
        _drawCurrent(current, canvas);
        if (editing) {
            _drawNext(next, canvas);
        }
    }

    @override
    bool shouldRepaint(covariant _SnowflakePainter oldDelegate) => true;
    
    void _drawCurrent(Render render, Canvas canvas) {
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

    void _drawNext(Render render, Canvas canvas) {
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
