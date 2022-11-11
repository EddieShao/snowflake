import 'dart:collection';
import 'dart:math';
import 'package:snowflake/utils.dart';

class Graph<T> {
    final HashMap<Node<T>, List<Edge?>> _nodes = HashMap();
    final T _rootValue;

    Graph(this._rootValue) {
        clear();
    }

    HashMap<Node<T>, List<Edge?>> state() => HashMap.of(_nodes);

    int depth() => _nodes.keys.map((node) => node.point.y).reduce(max);

    bool add(int fromX, int fromY, int toX, int toY, T value) {
        final from = _nodes.entries.find((e) => e.key.point.x == fromX && e.key.point.y == fromY);

        // "from" node must exist
        if (from == null) {
            return false;
        }

        // "to" node cannot be already connected to "from" node
        if (from.value.find((e) => e != null && e.to.x == toX && e.to.y == toY) != null) {
            return false;
        }

        final availableEdges = _availableEdgesFrom(fromX, fromY);
        const xOffsets = [-1, 0, 1, -1, 0, 1];
        const yOffsets = [1, 2, 1, -1, -2, -1];

        for (int i = 0; i < 6; i++) {
            final available = availableEdges[i];
            final isTarget = toX == fromX + xOffsets[i] && toY == fromY + yOffsets[i];

            if (available && isTarget) {
                MapEntry<Node<T>, List<Edge?>> createTo() {
                    final entry = MapEntry(
                        Node(Point(toX, toY), value),
                        List<Edge?>.filled(6, null)
                    );
                    _nodes.addEntries([entry]);
                    return entry;
                }

                final to = _nodes.entries.find((e) => e.key.point.x == toX && e.key.point.y == toY) ?? createTo();

                final fromPt = Point(from.key.point.x, from.key.point.y);
                final toPt = Point(to.key.point.x, to.key.point.y);

                from.value[i] = Edge(fromPt, toPt);
                to.value[5 - i] = Edge(toPt, fromPt);

                return true;
            }
        }

        return false;
    }

    bool update(int x, int y, T newValue) {
        final target = _nodes.keys.find((e) => e.point.x == x && e.point.y == y);
        if (target == null) {
            return false;
        }

        target.value = newValue;
        return true;
    }

    bool remove(int x1, int y1, int x2, int y2) {
        final p1 = _nodes.entries.find((e) => e.key.point.x == x1 && e.key.point.y == y1);
        final p2 = _nodes.entries.find((e) => e.key.point.x == x2 && e.key.point.y == y2);

        if (p1 == null || p2 == null || p1 == p2) {
            return false;
        }

        final MapEntry<Node<T>, List<Edge?>> leaf;
        final MapEntry<Node<T>, List<Edge?>> branch;

        if (p1.isLeafOf(p2) && p1.isNotRoot()) {
            leaf = p1;
            branch = p2;
        } else if (p2.isLeafOf(p1) && p2.isNotRoot()) {
            leaf = p2;
            branch = p1;
        } else {
            return false;
        }

        final leafIndex = branch.value.indexWhere((e) => e != null && e.to.x == leaf.key.point.x && e.to.y == leaf.key.point.y);
        if (leafIndex == -1) {
            return false;
        }

        branch.value[leafIndex] = null;
        _nodes.remove(leaf.key);

        return true;
    }

    void clear() {
        _nodes.clear();
        _nodes[Node(const Point(0, 0), _rootValue)] = List<Edge?>.filled(6, null);
    }

    List<bool> _availableEdgesFrom(int x, int y) {
        // indices: [lchild, mchild, rchild, lparent, mparent, rparent]
        final available = List<bool>.filled(6, true);

        if (y == 3 * x) {
            // right border node
            available[2] = false;
            available[4] = false;
            available[5] = false;
        } else if (y == 3 * x + 2) {
            // right outer node
            available[5] = false;
        }

        if (y == -3 * x) {
            // left border node
            available[0] = false;
            available[3] = false;
            available[4] = false;
        } else if (y == -3 * x + 2) {
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
}

class Node<T> {
    final Point point;
    T value;

    Node(this.point, this.value);
}

class Edge {
    final Point from;
    final Point to;

    const Edge(this.from, this.to);
}

extension<T> on MapEntry<Node<T>, List<Edge?>> {
    bool isLeafOf(MapEntry<Node<T>, List<Edge?>> other) =>
        value.find((e) => e != null && (e.to.x != other.key.point.x || e.to.y != other.key.point.y)) == null;
    
    bool isNotRoot() => key.point.x != 0 || key.point.y != 0;
}
