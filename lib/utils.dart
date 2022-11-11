class Pair<A, B> {
    final A first;
    final B second;

    const Pair(this.first, this.second);
}

extension IterableHelper<E> on Iterable<E> {
    E? find(bool Function(E e) condition) {
        try {
            return firstWhere((e) => condition(e));
        } on StateError {
            return null;
        }
    }

    Iterable<R> mapIndexed<R>(R Function(E e, int i) mapper) {
        final result = <R>[];
        for (int i = 0; i < length; i++) {
            result.add(mapper(elementAt(i), i));
        }
        return result;
    }
}
