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

        // render graphics for 1 arm of the snowflake
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

        List<Coordinate> nodes = List.from(armNodes); // nodes for all arms of the snowflake
        List<Pair<Coordinate, Coordinate>> edges = List.from(armEdges); // edges for all arms of the snowflake

        // perform 60 * n degree rotations on the entire arm to complete the snowflake
        for (int i = 1; i < 6; i++) {
            double angle = i * math.pi / 3;

            Coordinate rotate(Coordinate point) {
                return Coordinate(
                    point.x * math.cos(angle) - point.y * math.sin(angle),
                    point.x * math.sin(angle) + point.y * math.cos(angle)
                );
            }

            for (var node in armNodes) {
                nodes.add(rotate(node));
            }

            for (var edge in armEdges) {
                edges.add(Pair(rotate(edge.first), rotate(edge.second)));
            }
        }

        // radius of circle that fits perfectly in the canvas.
        double radius = size.width / 2;

        // move snowflake to center of canvas before returning
        return Render(
            nodes.map((node) => Coordinate(node.x + radius, node.y + radius)).toList(),
            edges.map((edge) => Pair(Coordinate(edge.first.x + radius, edge.first.y + radius), Coordinate(edge.second.x + radius, edge.second.y + radius))).toList()
        );
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
}
