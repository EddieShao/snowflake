import 'dart:collection';
import 'dart:math';
import 'package:snowflake/utils.dart';

/// An undirected graph that follows [triangle tiling](https://en.wikipedia.org/wiki/Triangular_tiling)
/// constrained to a 60 degree angle (1/6) slice.
class Graph<T> {
    final HashMap<Node<T>, List<Point?>> _nodes = HashMap();
    final T _rootValue;

    Graph(this._rootValue) {
        clear();
    }

    HashMap<Node<T>, List<Point?>> state() => HashMap.of(_nodes);

    /// Return a set of all edges that can be immediately added to this graph.
    Set<Pair<Point, Point>> next() {
        final free = <Pair<Point, Point>>{};

        const xOffsets = [-1, 0, 1, -1, 0, 1];
        const yOffsets = [1, 2, 1, -1, -2, -1];

        for (final entry in _nodes.entries) {
            final from = entry.key.point;
            final availability = _availableEdgesFrom(from);

            for (int i = 0; i < 6; i++) {
                if (availability[i] && entry.value[i] == null) {
                    free.add(Pair(from, Point(from.x + xOffsets[i], from.y + yOffsets[i])));
                }
            }
        }

        return free;
    }

    int depth() => _nodes.keys.map((node) => node.point.y).reduce(max);

    /// Add the given [edge] to this graph. If adding this [edge] also creates a new node, that node
    /// is assigned the given [value].
    /// 
    /// Return whether the add was successful or not.
    bool add(Pair<Point, Point> edge, T value) {
        final MapEntry<Node<T>, List<Point?>> from;
        final MapEntry<Node<T>, List<Point?>> to;

        final p1 = _nodes.entries.find((e) => e.key.point == edge.first);
        final p2 = _nodes.entries.find((e) => e.key.point == edge.second);

        if (p1 != null && p1.value.find((e) => e == edge.second) == null) {
            from = p1;
            to = p2 ?? _createNode(edge.second, value);
        } else if (p2 != null && p2.value.find((e) => e == edge.first) == null) {
            from = p2;
            to = p1 ?? _createNode(edge.first, value);
        } else {
            return false;
        }

        final availableEdges = _availableEdgesFrom(from.key.point);
        const xOffsets = [-1, 0, 1, -1, 0, 1];
        const yOffsets = [1, 2, 1, -1, -2, -1];

        for (int i = 0; i < 6; i++) {
            final available = availableEdges[i];
            final isTarget = to.key.point.x == from.key.point.x + xOffsets[i] && to.key.point.y == from.key.point.y + yOffsets[i];

            if (available && isTarget) {
                from.value[i] = Point(to.key.point.x, to.key.point.y);
                to.value[5 - i] = Point(from.key.point.x, from.key.point.y);
                return true;
            }
        }

        return false;
    }

    /// Update the node at [point] with the given [newValue].
    /// 
    /// Return whether the update was successful or not.
    bool update(Point point, T newValue) {
        final target = _nodes.keys.find((e) => e.point == point);

        if (target == null) {
            return false;
        }

        target.value = newValue;
        return true;
    }

    /// Remove the given [edge] from this graph.
    /// 
    /// Return whether the remove was successful or not.
    bool remove(Pair<Point, Point> edge) {
        final p1 = _nodes.entries.find((e) => e.key.point == edge.first);
        final p2 = _nodes.entries.find((e) => e.key.point == edge.second);

        if (p1 == null || p2 == null || p1 == p2) {
            return false;
        }

        final MapEntry<Node<T>, List<Point?>> leaf;
        final MapEntry<Node<T>, List<Point?>> branch;

        if (p1.isLeafOf(p2) && p1.isNotRoot()) {
            leaf = p1;
            branch = p2;
        } else if (p2.isLeafOf(p1) && p2.isNotRoot()) {
            leaf = p2;
            branch = p1;
        } else {
            return false;
        }

        final leafIndex = branch.value.indexWhere((e) => e != null && e.x == leaf.key.point.x && e.y == leaf.key.point.y);
        if (leafIndex == -1) {
            return false;
        }

        branch.value[leafIndex] = null;
        _nodes.remove(leaf.key);

        return true;
    }

    void clear() {
        _nodes.clear();
        _nodes[Node(const Point(0, 0), _rootValue)] = List<Point?>.filled(6, null);
    }

    MapEntry<Node<T>, List<Point?>> _createNode(Point point, T value) {
        final entry = MapEntry(
            Node(point, value),
            List<Point?>.filled(6, null)
        );
        _nodes.addEntries([entry]);
        return entry;
    }

    List<bool> _availableEdgesFrom(Point point) {
        // indices: [lchild, mchild, rchild, lparent, mparent, rparent]
        final available = List<bool>.filled(6, true);

        if (point.y == 3 * point.x) {
            // right border node
            available[2] = false;
            available[4] = false;
            available[5] = false;
        } else if (point.y == 3 * point.x + 2) {
            // right outer node
            available[5] = false;
        }

        if (point.y == -3 * point.x) {
            // left border node
            available[0] = false;
            available[3] = false;
            available[4] = false;
        } else if (point.y == -3 * point.x + 2) {
            // left outer node
            available[3] = false;
        }

        return available;
    }
}

class Point {
    final int x;
    final int y;

    const Point(this.x, this.y);

    @override
    operator ==(covariant Point other) => x == other.x && y == other.y;

    @override
    int get hashCode => Object.hash(x, y);
}

class Node<T> {
    final Point point;
    T value;

    Node(this.point, this.value);
}

extension<T> on MapEntry<Node<T>, List<Point?>> {
    bool isLeafOf(MapEntry<Node<T>, List<Point?>> other) =>
        value.find((e) => e != null && (e.x != other.key.point.x || e.y != other.key.point.y)) == null;
    
    bool isNotRoot() => key.point.x != 0 || key.point.y != 0;
}
