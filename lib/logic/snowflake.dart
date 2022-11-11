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

    final Graph<int> _graph = Graph(0);

    Render render(Size size) {
        int depth = _graph.depth();

        // edge length s.t. we can fit [depth] of them in a line on the canvas.
        double edgeLength = size.width / (depth % 2 == 0 ? depth : depth + 1);
        // 30 degrees
        double offsetAngle = math.pi / 6;

        // convert graph coordinates to screen coordinates
        Coordinate toScreen(int x, int y) {
            double hypotenuse = (y - x) / 2 * edgeLength;
            return Coordinate(
                hypotenuse * math.cos(offsetAngle),
                hypotenuse * math.sin(offsetAngle) + x * edgeLength
            );
        }

        List<Coordinate> armNodes = []; // nodes for 1 arm of the snowflake
        List<Pair<Coordinate, Coordinate>> armEdges = []; // edges for 1 arm of the snowflake

        // create blueprint for 1 arm of the snowflake
        _graph.state().forEach((node, connections) {
            // render this node; don't render the root
            Coordinate from = toScreen(node.point.x, node.point.y);
            if (node.point.x != 0 || node.point.y != 0) {
                armNodes.add(from);
            }

            // children
            var lchild = connections[0];
            var cchild = connections[1];
            var rchild = connections[2];

            // render edge to each non-null child
            if (lchild != null) {
                armEdges.add(Pair(from, toScreen(lchild.to.x, lchild.to.y)));
            }
            if (cchild != null) {
                armEdges.add(Pair(from, toScreen(cchild.to.x, cchild.to.y)));
            }
            if (rchild != null) {
                armEdges.add(Pair(from, toScreen(rchild.to.x, rchild.to.y)));
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

        return Render(nodes, edges);
    }

    bool add(int fromX, int fromY, int toX, int toY, int value) =>
        _graph.add(fromX, fromY, toX, toY, value);

    bool update(int x, int y, int newValue) =>
        _graph.update(x, y, newValue);

    bool remove(int fromX, int fromY, int toX, int toY) =>
        _graph.remove(fromX, fromY, toX, toY);

    void clear() => _graph.clear();
}

class Render {
    final List<Coordinate> nodes;
    final List<Pair<Coordinate, Coordinate>> edges;

    const Render(this.nodes, this.edges);
}

class Coordinate {
    final double x;
    final double y;

    const Coordinate(this.x, this.y);

    /// Rotate [angle] radians counter-clockwise about the origin.
    /// Done via matrix multiplication as follows (a == [angle]):
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
