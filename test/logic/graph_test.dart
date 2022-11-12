import 'package:test/test.dart';
import 'package:snowflake/logic/graph.dart';
import 'package:snowflake/utils.dart';

void main() {
    group("Graph", () {
        final graph = Graph(0);
        setUp(() {
            graph.clear();
        });
        group("depth()", () {
            test("Empty tree should have depth of 0.", () {
                expect(graph.depth(), 0);
            });
            test("Should have depth of node with highest y.", () {
                graph.add(const Pair(Point(0, 0), Point(0, 2)), 10);
                graph.add(const Pair(Point(0, 2), Point(0, 4)), 10);
                graph.add(const Pair(Point(0, 4), Point(-1, 5)), 10);
                graph.add(const Pair(Point(0, 4), Point(1, 5)), 10);
                expect(graph.depth(), 5);
            });
        });
        group("add()", () {
            test("Should not add out-of-bounds node.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(1, 1)), 0), false);
            });
            test("Should not add when starting from invalid node.", () {
                expect(graph.add(const Pair(Point(0, -2), Point(0, 2)), 0), false);
            });
            test("Should not add node that's not a direct child or parent", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 4)), 0), false);
            });
            test("Should not add node to itself.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 0)), 0), false);
            });
            test("Should add center child node to root.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 5), true);
            });
            test("Order of edge points should not matter.", () {
                expect(graph.add(const Pair(Point(0, 2), Point(0, 0)), 4), true);
            });
            test("Should not add already existing edge.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 5), true);
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 0), false);
                expect(graph.add(const Pair(Point(0, 2), Point(0, 0)), 4), false);
            });
            test("Should add all 3 children to an outer node.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 10), true);
                expect(graph.add(const Pair(Point(0, 2), Point(-1, 3)), 1), true);
                expect(graph.add(const Pair(Point(0, 2), Point(0, 4)), 2), true);
                expect(graph.add(const Pair(Point(0, 2), Point(1, 3)), 3), true);
            });
            test("Should add edge between 2 existing nodes.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 10), true);
                expect(graph.add(const Pair(Point(0, 2), Point(-1, 3)), 1), true);
                expect(graph.add(const Pair(Point(0, 2), Point(0, 4)), 2), true);
                expect(graph.add(const Pair(Point(-1, 3), Point(0, 4)), -6), true);
            });
            test("Should not add side child, side parent, nor center parent of border node.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 10), true);
                expect(graph.add(const Pair(Point(0, 2), Point(1, 3)), 1), true);
                expect(graph.add(const Pair(Point(1, 3), Point(2, 4)), 0), false);
                expect(graph.add(const Pair(Point(1, 3), Point(2, 2)), 0), false);
                expect(graph.add(const Pair(Point(1, 3), Point(1, 1)), 0), false);
            });
            test("Should not add side parent of outer node.", () {
                expect(graph.add(const Pair(Point(0, 0), Point(0, 2)), 10), true);
                expect(graph.add(const Pair(Point(0, 2), Point(-1, 1)), 0), false);
            });
        });
        group("update()", () {
            test("Should not update invalid node.", () {
                expect(graph.update(const Point(0, 2), 10), false);
            });
            test("Should update existing node.", () {
                expect(graph.update(const Point(0, 0), 10), true);
            });
        });
        group("remove()", () {
            test("Should not remove invalid edge.", () {
                expect(graph.remove(const Pair(Point(0, 0), Point(1, 1))), false);
            });
            test("Should not remove edge pointing to itself.", () {
                expect(graph.remove(const Pair(Point(0, 0), Point(0, 0))), false);
            });
            test("Should remove leaf edge.", () {
                graph.add(const Pair(Point(0, 0), Point(0, 2)), 3);
                expect(graph.remove(const Pair(Point(0, 0), Point(0, 2))), true);
                expect(graph.remove(const Pair(Point(0, 0), Point(0, 2))), false);
            });
            test("Order of (x, y) inputs should not matter.", () {
                graph.add(const Pair(Point(0, 0), Point(0, 2)), 5);
                expect(graph.remove(const Pair(Point(0, 2), Point(0, 0))), true);
                expect(graph.remove(const Pair(Point(0, 2), Point(0, 0))), false);
            });
            test("Should not remove non-leaf edge.", () {
                graph.add(const Pair(Point(0, 0), Point(0, 2)), 1);
                expect(graph.add(const Pair(Point(0, 2), Point(-1, 3)), 10), true);
                expect(graph.remove(const Pair(Point(0, 0), Point(0, 2))), false);
            });
            test("Should never remove root.", () {
                graph.add(const Pair(Point(0, 0), Point(0, 2)), 40);
                expect(graph.remove(const Pair(Point(0, 2), Point(0, 0))), true);
                expect(graph.add(const Pair(Point(0, 2), Point(-1, 3)), 1), false);
                graph.add(const Pair(Point(0, 0), Point(0, 2)), 20);
                expect(graph.remove(const Pair(Point(0, 0), Point(0, 2))), true);
                expect(graph.add(const Pair(Point(0, 2), Point(-1, 3)), 1), false);
            });
        });
    });
}
