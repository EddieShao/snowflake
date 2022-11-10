import 'dart:math';

class Graph<T> {
    final T _; // Default value of a node.
    Map<Node<T>, List<Node<T>?>> _data = {};

    Graph(this._) {
        _data[Node(0, 0, _)] = _list6(null);
    }

    Map<Node<T>, List<Node<T>?>> get() {
        return Map<Node<T>, List<Node<T>?>>.from(_data);
    }

    int depth() {
        return _data.keys.map((node) => node.y).reduce(max);
    }

    bool add(int fromX, int fromY, int toX, int toY, T? value) {
        Node<T> from = Node(fromX, fromY, _);
        List<Node<T>?>? connsFrom = _data[from];
        if (connsFrom == null) {
            return false;
        }

        Node<T> to = Node(toX, toY, value ?? _);
        if (connsFrom.contains(to)) {
            return false;
        }

        // lchild, cchild, rchild, lparent, cparent, rparent
        List<bool> availConns = _list6(true);
        List<int> xOffsets = [-1, 0, 1, -1, 0, 1];
        List<int> yOffsets = [1, 2, 1, -1, -2, -1];
        if (fromY == 3 * fromX) {
            // right border node
            availConns[2] = false;
            availConns[4] = false;
            availConns[5] = false;
        } else if (fromY == 3 * fromX + 2) {
            // right outer node
            availConns[5] = false;
        }
        if (fromY == -3 * fromX) {
            // left border node
            availConns[0] = false;
            availConns[3] = false;
            availConns[4] = false;
        } else if (fromY == -3 * fromX + 2) {
            // left outer node
            availConns[3] = false;
        }

        for (int i = 0; i < 6; i++) {
            if (availConns[i] && toX == fromX + xOffsets[i] && toY == fromY + yOffsets[i]) {
                connsFrom[i] = to;
                _data.putIfAbsent(to, () => _list6(null))[5 - i] = from;
                return true;
            }
        }

        return false;
    }

    void clear() {
        _data = {
            Node(0, 0, _): _list6(null)
        };
    }
}

class Node<T> {
    final int x;
    final int y;
    T value;

    Node(this.x, this.y, this.value);

    @override
    bool operator ==(Object other) =>
        other is Node && other.runtimeType == runtimeType && other.x == x && other.y == y;
        
    @override
    int get hashCode => Object.hash(x, y);

    @override
    String toString() {
        return "($x, $y, $value)";
    }
}

List<K> _list6<K>(K value) {
    return [value, value, value, value, value, value];
}
