import 'package:test/test.dart';
import 'package:snowflake/logic/graph.dart';

void main() {
    group("Graph", () {
        group("add()", () {
            final graph = Graph(0);
            test("Should not add out-of-bounds node.", () {
                expect(graph.add(0, 0, 1, 1, 0), false);
            });
            test("Should not add when starting from invalid node.", () {
                expect(graph.add(0, -2, 0, 2, 0), false);
            });
            test("Should not add node that's not a direct child or parent", () {
                expect(graph.add(0, 0, 0, 4, 0), false);
            });
            test("Should not add node to itself.", () {
                expect(graph.add(0, 0, 0, 0, 0), false);
            });
            test("Should add center child node to root.", () {
                expect(graph.add(0, 0, 0, 2, 5), true);
            });
            test("Should not add same edge in the opposite direction.", () {
                expect(graph.add(0, 2, 0, 0, 0), false);
            });
            test("Should not add already existing node.", () {
                expect(graph.add(0, 0, 0, 2, 0), false);
            });
            test("Should add all 3 children to outer node.", () {
                expect(graph.add(0, 2, -1, 3, 1), true);
                expect(graph.add(0, 2, 0, 4, 2), true);
                expect(graph.add(0, 2, 1, 3, 3), true);
            });
            test("Should add edge between 2 existing nodes.", () {
                expect(graph.add(-1, 3, 0, 4, 0), true);
            });
            test("Should not add side child, side parent, nor center parent of border node.", () {
                expect(graph.add(1, 3, 2, 4, 0), false);
                expect(graph.add(1, 3, 2, 2, 0), false);
                expect(graph.add(1, 3, 1, 1, 0), false);
            });
            test("Should not add side parent of outer node.", () {
                expect(graph.add(0, 2, -1, 1, 0), false);
            });
        });
        group("update()", () {
            final graph = Graph(0);
            test("Should not update invalid node.", () {
                expect(graph.update(0, 2, 10), false);
            });
            test("Should update existing node.", () {
                expect(graph.update(0, 0, 10), true);
            });
        });
        group("remove()", () {
            final graph = Graph(0);
            test("Should not remove invalid edge.", () {
                expect(graph.remove(0, 0, 1, 1), false);
            });
            test("Should not remove edge pointing to itself.", () {
                expect(graph.remove(0, 0, 0, 0), false);
            });
            test("Should remove leaf edge.", () {
                graph.add(0, 0, 0, 2, 3);
                expect(graph.remove(0, 0, 0, 2), true);
                expect(graph.remove(0, 0, 0, 2), false);
            });
            test("Order of (x, y) inputs should not matter.", () {
                graph.add(0, 0, 0, 2, 5);
                expect(graph.remove(0, 2, 0, 0), true);
                expect(graph.remove(0, 2, 0, 0), false);
            });
            test("Should not remove non-leaf edge.", () {
                graph.add(0, 0, 0, 2, 1);
                graph.add(0, 2, -1, 3, 10);
                expect(graph.remove(0, 0, 0, 2), false);
            });
            test("Should never remove root.", () {
                graph.clear();
                graph.add(0, 0, 0, 2, 40);
                expect(graph.remove(0, 2, 0, 0), true);
                expect(graph.add(0, 2, -1, 3, 1), false);
                graph.add(0, 0, 0, 2, 20);
                expect(graph.remove(0, 0, 0, 2), true);
                expect(graph.add(0, 2, -1, 3, 1), false);
            });
        });
    });
}
