import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snowflake/app_state.dart';
import 'dart:math' as math;
import 'package:snowflake/theme.dart' as theme;
import 'package:snowflake/logic/snowflake.dart';
import 'package:snowflake/utils.dart';

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
        final sf = Snowflake();
        sf
            ..clear()
            ..add(0, 0, 0, 2)
            ..add(0, 2, -1, 3)
            ..add(-1, 3, -1, 5)
            ..add(-1, 5, 0, 6)
            ..add(0, 6, 1, 5)
            ..add(0, 6, -1, 7)
            ..add(0, 6, 1, 7)
            ..add(0, 6, 0, 8)
            ..add(0, 6, 0, 4);
        
        // for (int i = 4; i < 40; i++) {
        //     sf.add(0, i * 2, 0, i * 2 + 2);
        // }

        sf.update(0, 2, NodeType.square);
        sf.update(-1, 7, NodeType.square);
        sf.update(0, 8, NodeType.square);
        sf.update(1, 7, NodeType.square);
    }

    @override
    Widget build(BuildContext context) {
        final sf = Snowflake();

        final contextSize = MediaQuery.of(context).size;
        final canvasSize = Size.square(math.min(contextSize.width, contextSize.height) - 10);

        Render<NodeType> all() => sf.renderAll(canvasSize);
        Render<NodeType> one() => sf.renderOne(canvasSize);
        Render<NodeType> next() => sf.renderNext(canvasSize);

        final body = Center(
            child: GestureDetector(
                // TODO: implement touch actions
                child: Consumer<EditState>(
                    builder: (context, editState, child) {
                        return CustomPaint(
                            painter: _SnowflakePainter(editState.value),
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

    const _SnowflakePainter(this.editing);

    @override
    void paint(Canvas canvas, Size size) {
        final sf = Snowflake();
        final edgeWidth = _scaleEdgeWidth(sf.depth());
        final paletteAll = Palette(
            edgePaint: Paint()
                ..color = theme.white.withOpacity(editing ? 0.15 : 1)
                ..strokeWidth = edgeWidth
                ..style = PaintingStyle.stroke,
            defaultNodePaint: Paint()
                ..color = theme.white.withOpacity(editing ? 0.15 : 1)
                ..strokeWidth = 0
                ..style = PaintingStyle.fill,
        );
        _draw(sf.renderAll(size), canvas, paletteAll);

        if (editing) {
            final editColor = theme.getEditEdgeColor();
            final paletteNext = Palette(
                edgePaint: Paint()
                    ..color = editColor.withOpacity(0.2)
                    ..strokeWidth = edgeWidth
                    ..style = PaintingStyle.stroke,
                defaultNodePaint: Paint()
                    ..color = editColor.withOpacity(0.2)
                    ..strokeWidth = 0
                    ..style = PaintingStyle.fill,
            );
            final paletteOne = Palette(
                edgePaint: Paint()
                    ..color = theme.white
                    ..strokeWidth = edgeWidth
                    ..style = PaintingStyle.stroke,
                defaultNodePaint: Paint()
                    ..color = theme.white
                    ..strokeWidth = 0
                    ..style = PaintingStyle.fill,
            );
            _draw(sf.renderNext(size), canvas, paletteNext);
            _draw(sf.renderOne(size), canvas, paletteOne);
        }
    }

    @override
    bool shouldRepaint(covariant _SnowflakePainter oldDelegate) => true;

    void _draw(Render<NodeType> render, Canvas canvas, Palette palette) {
        for (final edge in render.edges.values.flatten()) {
            canvas.drawLine(
                Offset(edge.first.x, edge.first.y),
                Offset(edge.second.x, edge.second.y),
                palette.edgePaint
            );
        }

        double nodeWidth = _scaleNodeWidth(Snowflake().depth());

        final nodes = render.nodes.entries.map((entry) => entry.value.map((coord) => Pair(entry.key, coord))).flatten();
        for (final node in nodes) {
            _drawNode(node.first.value, Offset(node.second.x, node.second.y), nodeWidth, canvas, palette);
        }
    }

    void _drawNode(NodeType type, Offset loc, double nodeWidth, Canvas canvas, Palette palette) {
        switch(type) {
            case NodeType.circle: {
                canvas.drawCircle(loc, nodeWidth / 2, palette.defaultNodePaint);
            }
            break;

            case NodeType.square: {
                canvas.drawRect(Rect.fromCenter(center: loc, width: nodeWidth, height: nodeWidth), palette.defaultNodePaint);
            }
            break;
        }
    }

    // The numbers for these methods were picked by trial and error. If there's a better way to
    //  determine these numbers, please do so.
    double _scaleEdgeWidth(int depth) => math.min(5, 16 / depth);
    double _scaleNodeWidth(int depth) => 28 / math.pow(depth, 0.63);
}

class Palette {
    final Paint edgePaint;
    final Paint defaultNodePaint;

    const Palette({
        required this.edgePaint,
        required this.defaultNodePaint
    });
}

extension<E> on Iterable<Iterable<E>> {
    Iterable<E> flatten() => [for (final sub in this) ...sub];
}
