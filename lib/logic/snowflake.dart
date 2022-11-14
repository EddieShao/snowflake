import 'dart:collection';
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

    final Graph<NodeType> _arm = Graph(NodeType.circle);

    /// Return geometry data of the entire snowflake. The render fits inside a canvas with the
    /// given [size].
    Render<NodeType> renderAll(Size size) {
        final converted = _convertArm(size);
        final armNodes = converted.first; // nodes for 1 arm of the snowflake
        final armEdges = converted.second; // edges for 1 arm of the snowflake

        final nodes = HashMap<Node<NodeType>, List<Coordinate>>(); // nodes for full snowflake
        final edges = HashMap<Edge<Point>, List<Edge<Coordinate>>>(); // edges for full snowflake

        // use blueprint to render all 6 arms and complete the snowflake
        for (int i = 0; i < 6; i++) {
            double angle = i * math.pi / 3;

            for (final entry in armNodes.entries) {
                nodes.putIfAbsent(entry.key, () => []).add(entry.value.rotate(angle).center(size));
            }

            for (final entry in armEdges.entries) {
                edges.putIfAbsent(entry.key, () => []).add(
                    Pair(
                        entry.value.first.rotate(angle).center(size),
                        entry.value.second.rotate(angle).center(size)
                    )
                );
            }
        }

        return Render(nodes, edges);
    }

    /// Return geometry data for 1 arm of this snowflake. The render fits inside a canvas with the
    /// given [size].
    Render<NodeType> renderOne(Size size) {
        final converted = _convertArm(size);
        final nodes = HashMap<Node<NodeType>, List<Coordinate>>();
        final edges = HashMap<Edge<Point>, List<Edge<Coordinate>>>();

        for (final entry in converted.first.entries) {
            nodes[entry.key] = [entry.value.center(size)];
        }

        for (final entry in converted.second.entries) {
            edges[entry.key] = [Pair(entry.value.first.center(size), entry.value.second.center(size))];
        }

        return Render(nodes, edges);
    }

    /// Return geometry data of all possible next edges in this snowflake. The render fits inside a
    /// canvas with the given [size].
    Render<NodeType> renderNext(Size size) {
        final next = _arm.next();

        final nodes = next.first.map((node) => MapEntry(node, [_toScreen(node.point, size.width).center(size)]));
        final edges = next.second.map((edge) =>
            MapEntry(edge, [Pair(_toScreen(edge.first, size.width).center(size), _toScreen(edge.second, size.width).center(size))])
        );

        return Render(HashMap.fromEntries(nodes), HashMap.fromEntries(edges));
    }

    int depth() => _arm.depth();

    bool add(int x1, int y1, int x2, int y2) =>
        _arm.add(Pair(Point(x1, y1), Point(x2, y2)), NodeType.circle);

    bool update(int x, int y, NodeType newType) =>
        _arm.update(Point(x, y), newType);

    bool remove(int x1, int y1, int x2, int y2) =>
        _arm.remove(Pair(Point(x1, y1), Point(x2, y2)));

    void clear() => _arm.clear();

    Coordinate _toScreen(Point point, double canvasLength) {
        int depth = _arm.depth() + 2;

        // edge length s.t. we can fit [depth] of them in a line on the canvas.
        double edgeLength = canvasLength / (depth % 2 == 0 ? depth : depth + 1);
        // 30 degrees
        double offsetAngle = math.pi / 6;

        // convert graph coordinates to screen coordinates
        double hypotenuse = (point.y - point.x) / 2 * edgeLength;
        return Coordinate(
            hypotenuse * math.cos(offsetAngle),
            hypotenuse * math.sin(offsetAngle) + point.x * edgeLength
        ).rotate(3 * math.pi / 2 - offsetAngle);
    }

    Pair<HashMap<Node<NodeType>, Coordinate>, HashMap<Edge<Point>, Edge<Coordinate>>> _convertArm(Size size) {
        final nodes = HashMap<Node<NodeType>, Coordinate>(); // nodes for 1 arm of the snowflake
        final edges = HashMap<Edge<Point>, Edge<Coordinate>>(); // edges for 1 arm of the snowflake

        // create blueprint for 1 arm of the snowflake
        _arm.state().forEach((node, connections) {
            // render this node; don't render the root
            Coordinate from = _toScreen(node.point, size.width);
            if (node.point.x != 0 || node.point.y != 0) {
                nodes[node] = from;
            }

            // children
            var lchild = connections[0];
            var cchild = connections[1];
            var rchild = connections[2];

            // render edge to each non-null child
            if (lchild != null) {
                edges[Pair(node.point, lchild)] = Pair(from, _toScreen(lchild, size.width));
            }
            if (cchild != null) {
                edges[Pair(node.point, cchild)] = Pair(from, _toScreen(cchild, size.width));
            }
            if (rchild != null) {
                edges[Pair(node.point, rchild)] = Pair(from, _toScreen(rchild, size.width));
            }
        });

        return Pair(nodes, edges);
    }
}

typedef Edge<T> = Pair<T, T>;

class Render<T> {
    final HashMap<Node<T>, List<Coordinate>> nodes;
    final HashMap<Edge<Point>, List<Edge<Coordinate>>> edges;

    const Render(this.nodes, this.edges);
}

class Coordinate {
    final double x;
    final double y;

    const Coordinate(this.x, this.y);

    @override
    operator ==(covariant Coordinate other) => x == other.x && y == other.y;

    @override
    int get hashCode => Object.hash(x, y);

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

enum NodeType {
    circle,
    square
}
