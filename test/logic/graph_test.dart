import 'package:test/test.dart';
import 'package:snowflake/logic/graph.dart';

void main() {
    group("Graph", () {
        group("add()", () {
            Graph<int> graph = Graph(0);
            test("Should fail to add out-of-bounds node.", () {
                expect(graph.add(0, 0, 1, 0, null), false);
                expect(graph.add(0, 0, -1, 1, null), false);
            });
            test("Should not add when starting from invalid node.", () {
                expect(graph.add(0, -2, 0, 2, null), false);
                expect(graph.add(0, 2, 1, 3, null), false);
            });
            test("Should not add node that's not a direct child or parent", () {
                expect(graph.add(0, 0, 0, 4, null), false);
                expect(graph.add(0, 0, -1, 3, null), false);
            });
            test("Should not add node to itself.", () {
                expect(graph.add(0, 0, 0, 0, null), false);
            });
            test("Should add center child node to root.", () {
                expect(graph.add(0, 0, 0, 2, null), true);
                print(graph.data);
            });
            test("Should not add same edge in the opposite direction.", () {
                expect(graph.add(0, 2, 0, 0, null), false);
            });
            test("Should not add already existing node.", () {
                expect(graph.add(0, 0, 0, 2, null), false);
            });
            test("Should add all 3 children to outer node.", () {
                expect(graph.add(0, 2, -1, 3, null), true);
                expect(graph.add(0, 2, 0, 4, null), true);
                expect(graph.add(0, 2, 1, 3, null), true);
            });
            test("Should add edge between 2 existing node.", () {
                expect(graph.add(-1, 3, 0, 4, null), true);
            });
            test("Should add parent of node", () {
                expect(graph.add(0, 4, 1, 3, null), true);
            });
            test("Should not add side child, side parent, nor center parent of border node.", () {
                expect(graph.add(1, 3, 2, 4, null), false);
                expect(graph.add(1, 3, 2, 2, null), false);
                expect(graph.add(1, 3, 1, 1, null), false);
            });
            test("Should not add side parent of outer node.", () {
                expect(graph.add(0, 2, -1, 1, null), false);
            });
            test("Should add all connections of inner node.", () {
                expect(graph.add(0, 4, 0, 6, null), true);
                expect(graph.add(0, 6, -1, 7, null), true);
                expect(graph.add(0, 6, 0, 8, null), true);
                expect(graph.add(0, 6, 1, 7, null), true);
                expect(graph.add(0, 6, -1, 5, null), true);
                expect(graph.add(0, 6, 1, 5, null), true);
            });
        });
    });
}
