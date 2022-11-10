import 'dart:math';

class Graph<T> {
    final T defaultValue; // Default value of a node.
    Map<Node<T>, List<Node<T>?>> data = {};

    Graph(this.defaultValue) {
        data[Node(0, 0, defaultValue)] = list6(null);
    }

    Map<Node<T>, List<Node<T>?>> get() {
        return Map<Node<T>, List<Node<T>?>>.from(data);
    }

    int depth() {
        return data.keys.map((node) => node.y).reduce(max);
    }

    bool add(int fromX, int fromY, int toX, int toY, T? value) {
        // from node must exist
        Node<T> from;
        try {
            from = data.keys.firstWhere((node) => node.locEq(fromX, fromY));
        } on StateError {
            return false;
        }

        // to node must not exist in from node's connections
        if (data[from]?.any((node) => node != null && node.locEq(toX, toY)) == true) {
            return false;
        }

        // indices: lchild, cchild, rchild, lparent, cparent, rparent
        List<bool> availConns = list6(true);
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

        // find valid location to insert new edge
        for (int i = 0; i < 6; i++) {
            if (availConns[i] && toX == fromX + xOffsets[i] && toY == fromY + yOffsets[i]) {
                // get existing "to" node or create a new one
                Node<T> to;
                try {
                    to = data.keys.firstWhere((node) => node.locEq(toX, toY));
                } on StateError {
                    to = Node(toX, toY, value ?? defaultValue);
                    data[to] = list6(null);
                }

                // insert edge
                data[to]![5 - i] = from;
                data[from]![i] = to;

                return true;
            }
        }

        // no valid location was found for new node
        return false;
    }

    T? update(int x, int y, T newValue) {
        try {
            var target = data.keys.firstWhere((node) => node.locEq(x, y));
            var oldValue = target.value;
            target.value = newValue;
            return oldValue;
        } on StateError {
            return null;
        }
    }

    void clear() {
        data = {
            Node(0, 0, defaultValue): list6(null)
        };
    }
}

class Node<T> {
    final int x;
    final int y;
    T value;

    Node(this.x, this.y, this.value);

    bool locEq(int x, int y) => this.x == x && this.y == y;
}

List<K> list6<K>(K value) {
    return [value, value, value, value, value, value];
}
