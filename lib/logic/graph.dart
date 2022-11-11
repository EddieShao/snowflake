import 'dart:collection';
import 'dart:math';

typedef Edges<T> = List<Node<T>?>;

class Graph<T> {
    final HashMap<Node<T>, Edges<T>> nodes = HashMap();
    final T _rootValue;

    Graph(this._rootValue) {
        nodes[Node(0, 0, _rootValue)] = Edges.filled(6, null);
    }

    HashMap<Node<T>, Edges<T>> state() => HashMap.of(nodes);

    int depth() => nodes.keys.map((node) => node.y).reduce(max);

    bool add(int fromX, int fromY, int toX, int toY, T value) {
        // "from" node must exist
        final from = nodes.keys.find((e) => e.x == fromX && e.y == fromY);
        if (from == null) {
            return false;
        }

        // "to" node cannot be connected to "from" node
        if (nodes[from]?.find((e) => e != null && e.x == toX && e.y == toY) != null) {
            return false;
        }

        final availableEdges = availableEdgesFrom(fromX, fromY);
        const xOffsets = [-1, 0, 1, -1, 0, 1];
        const yOffsets = [1, 2, 1, -1, -2, -1];

        for (int i = 0; i < 6; i++) {
            final available = availableEdges[i];
            final isTarget = toX == fromX + xOffsets[i] && toY == fromY + yOffsets[i];

            if (available && isTarget) {
                Node<T> createTo() {
                    final Node<T> tmp = Node(toX, toY, value);
                    nodes[tmp] = Edges.filled(6, null);
                    return tmp;
                }

                final to = nodes.keys.find((e) => e.x == toX && e.y == toY) ?? createTo();

                nodes[from]?[i] = to;
                nodes[to]?[5 - i] = from;

                return true;
            }
        }

        return false;
    }

    bool update(int x, int y, T newValue) {
        final target = nodes.keys.find((e) => e.x == x && e.y == y);
        if (target == null) {
            return false;
        }

        target.value = newValue;
        return true;
    }

    bool remove(int fromX, int fromY, int toX, int toY) {
        final from = nodes.keys.find((e) => e.x == fromX && e.y == fromY);
        final to = nodes[from]?.find((e) => e != null && e.x == toX && e.y == toY);
        final toConnections = nodes[to];

        if (from == null || to == null || toConnections == null) {
            return false;
        }

        final isLeaf = toConnections.find((e) => e != null && (e.x != fromX || e.y != fromY)) == null;
        final toIndex = nodes[from]?.indexOf(to) ?? -1;
        final fromIndex = nodes[to]?.indexOf(from) ?? -1;

        if (isLeaf && toIndex != -1 && fromIndex != -1) {
            nodes[from]?[toIndex] = null;
            nodes.remove(to);
            return true;
        }

        return false;
    }

    void clear() {
        nodes.clear();
        nodes[Node(0, 0, _rootValue)] = Edges.filled(6, null);
    }

    List<bool> availableEdgesFrom(int x, int y) {
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

class Node<T> {
    int x;
    int y;
    T value;

    Node(this.x, this.y, this.value);
}

extension IterableHelper<E> on Iterable<E> {
    E? find(bool Function(E e) condition) {
        try {
            return firstWhere((e) => condition(e));
        } on StateError {
            return null;
        }
    }
}
