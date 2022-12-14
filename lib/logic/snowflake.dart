import 'package:snowflake/logic/graph.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:snowflake/utils.dart' show Pair;

class Snowflake {
    static final Snowflake _snowflake = Snowflake._internal();
    final Graph<int> _graph = Graph(0);

    factory Snowflake() {
        return _snowflake;
    }

    Snowflake._internal();

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
        _graph.get().forEach((node, connections) {
            // render this node
            Coordinate from = toScreen(node.x, node.y);
            armNodes.add(from);

            // children
            var lchild = connections[0];
            var cchild = connections[1];
            var rchild = connections[2];

            // render edge to each non-null child
            if (lchild != null) {
                armEdges.add(Pair(from, toScreen(lchild.x, lchild.y)));
            }
            if (cchild != null) {
                armEdges.add(Pair(from, toScreen(cchild.x, cchild.y)));
            }
            if (rchild != null) {
                armEdges.add(Pair(from, toScreen(rchild.x, rchild.y)));
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

        // move snowflake to center of canvas before returning
        return Render(nodes, edges);
    }

    bool add(int fromX, int fromY, int toX, int toY) {
        return _graph.add(fromX, fromY, toX, toY, null);
    }

    void clear() {
        _graph.clear();
    }
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
    ///  ???              ???   ??? ???
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
