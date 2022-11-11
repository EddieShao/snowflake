import 'dart:collection';
import 'dart:math';

typedef Edges<T> = List<Node<T>?>;

class Graph<T> {
    final HashMap<Node<T>, Edges<T>> nodes = HashMap();

    Graph(T rootValue) {
        nodes[Node(0, 0, rootValue)] = Edges.filled(6, null);
    }

    HashMap<Node<T>, Edges<T>> get() => HashMap.of(nodes);

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

        // indices: [lchild, mchild, rchild, lparent, mparent, rparent]
        final availableEdges = List<bool>.filled(6, true);
        const xOffsets = [-1, 0, 1, -1, 0, 1];
        const yOffsets = [1, 2, 1, -1, -2, -1];

        if (fromY == 3 * fromX) {
            // right border node
            availableEdges[2] = false;
            availableEdges[4] = false;
            availableEdges[5] = false;
        } else if (fromY == 3 * fromX + 2) {
            // right outer node
            availableEdges[5] = false;
        }

        if (fromY == -3 * fromX) {
            // left border node
            availableEdges[0] = false;
            availableEdges[3] = false;
            availableEdges[4] = false;
        } else if (fromY == -3 * fromX + 2) {
            // left outer node
            availableEdges[3] = false;
        }

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

    void clear() {
        nodes.clear();
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
