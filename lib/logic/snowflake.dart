import 'package:snowflake/logic/graph.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:snowflake/utils.dart';

class Snowflake {
    static final Snowflake _snowflake = Snowflake._internal();

    factory Snowflake() {
        return _snowflake;
    }

    Snowflake._internal();

    final Graph<int> _arm = Graph(0);
    bool showNext = false;

    /// Return geometry data of the current snowflake. The render fits inside a canvas with the
    /// given [size].
    /// 
    /// If [showNext] is true, the next available edges of the snowflake will be rendered as well.
    Render render(Size size) {
        int depth = showNext ? _arm.depth() + 2 : _arm.depth();

        // edge length s.t. we can fit [depth] of them in a line on the canvas.
        double edgeLength = size.width / (depth % 2 == 0 ? depth : depth + 1);
        // 30 degrees
        double offsetAngle = math.pi / 6;

        // convert graph coordinates to screen coordinates
        Coordinate toScreen(Point point) {
            double hypotenuse = (point.y - point.x) / 2 * edgeLength;
            return Coordinate(
                hypotenuse * math.cos(offsetAngle),
                hypotenuse * math.sin(offsetAngle) + point.x * edgeLength
            );
        }

        List<Coordinate> armNodes = []; // nodes for 1 arm of the snowflake
        List<Pair<Coordinate, Coordinate>> armEdges = []; // edges for 1 arm of the snowflake

        // create blueprint for 1 arm of the snowflake
        _arm.state().forEach((node, connections) {
            // render this node; don't render the root
            Coordinate from = toScreen(node.point);
            if (node.point.x != 0 || node.point.y != 0) {
                armNodes.add(from);
            }

            // children
            var lchild = connections[0];
            var cchild = connections[1];
            var rchild = connections[2];

            // render edge to each non-null child
            if (lchild != null) {
                armEdges.add(Pair(from, toScreen(lchild)));
            }
            if (cchild != null) {
                armEdges.add(Pair(from, toScreen(cchild)));
            }
            if (rchild != null) {
                armEdges.add(Pair(from, toScreen(rchild)));
            }
        });

        List<Coordinate> nodes = []; // nodes for full snowflake
        List<Pair<Coordinate, Coordinate>> edges = []; // edges for full snowflake

        // use blueprint to render all 6 arms and complete the snowflake
        for (int i = 0; i < 6; i++) {
            double angle = i * math.pi / 3;

            for (var node in armNodes) {
                nodes.add(node.rotate(angle).center(size));
            }

            for (var edge in armEdges) {
                edges.add(
                    Pair(
                        edge.first.rotate(angle).center(size),
                        edge.second.rotate(angle).center(size)
                    )
                );
            }
        }

        final List<Pair<Coordinate, Coordinate>> nextEdges = [];
        if (showNext) {
            final armNextEdges = _arm.next().map((edge) => Pair(toScreen(edge.first), toScreen(edge.second)));

            for (int i = 0; i < 6; i++) {
                double angle = i * math.pi / 3;

                for (final edge in armNextEdges) {
                    nextEdges.add(
                        Pair(
                            edge.first.rotate(angle).center(size),
                            edge.second.rotate(angle).center(size)
                        )
                    );
                }
            }
        }

        return Render(nodes, edges, nextEdges);
    }

    bool add(int x1, int y1, int x2, int y2, int value) =>
        _arm.add(Pair(Point(x1, y1), Point(x2, y2)), value);

    bool update(int x, int y, int newValue) =>
        _arm.update(Point(x, y), newValue);

    bool remove(int x1, int y1, int x2, int y2) =>
        _arm.remove(Pair(Point(x1, y1), Point(x2, y2)));

    void clear() => _arm.clear();
}

class Render {
    final List<Coordinate> nodes;
    final List<Pair<Coordinate, Coordinate>> edges;
    final List<Pair<Coordinate, Coordinate>> nextEdges;

    const Render(this.nodes, this.edges, this.nextEdges);
}

class Coordinate {
    final double x;
    final double y;

    const Coordinate(this.x, this.y);

    /// Rotate [angle] radians counter-clockwise about the origin.
    /// Done via multiplying the coordinate by the rotation matrix as follows (a == [angle]):
    ///  _              _   _ _
    /// | cos(a) -sin(a) | |[x]|
    /// | sin(a)  cos(a) | |[y]|
    ///  ‾              ‾   ‾ ‾
    Coordinate rotate(double angle) {
        return Coordinate(
            x * math.cos(angle) - y * math.sin(angle),
            x * math.sin(angle) + y * math.cos(angle)
        );
    }

    /// Assuming this coordinate is relative to the origin (top-left corner), shift it s.t. the origin
    /// is now at the center of the canvas with the given [size].
    Coordinate center(Size size) {
        return Coordinate(x + size.width / 2, y + size.height / 2);
    }
}
