import 'package:test/test.dart';
import 'package:snowflake/logic/graph.dart';

void main() {
    group("Graph", () {
        group("add()", () {
            int defaultValue = 0;
            Graph<int> graph = Graph(defaultValue);
            test("Should fail to add out-of-bounds node.", () {
                expect(graph.add(0, 0, 1, 1, null), false);
                expect(graph.data.keys.length, 1);
                expect(graph.data[graph.data.keys.first]?.every((conn) => conn == null), true);
            });
            test("Should not add when starting from invalid node.", () {
                expect(graph.add(0, -2, 0, 2, null), false);
                expect(graph.data.keys.length, 1);
                expect(graph.data[graph.data.keys.first]?.every((conn) => conn == null), true);
            });
            test("Should not add node that's not a direct child or parent", () {
                expect(graph.add(0, 0, 0, 4, null), false);
                expect(graph.data.keys.length, 1);
                expect(graph.data[graph.data.keys.first]?.every((conn) => conn == null), true);
            });
            test("Should not add node to itself.", () {
                expect(graph.add(0, 0, 0, 0, null), false);
                expect(graph.data.keys.length, 1);
                expect(graph.data[graph.data.keys.first]?.every((conn) => conn == null), true);
            });
            test("Should add center child node to root.", () {
                expect(graph.add(0, 0, 0, 2, 5), true);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [null, null, null, null, n0_0, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                }
            });
            test("Should not add same edge in the opposite direction.", () {
                expect(graph.add(0, 2, 0, 0, null), false);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [null, null, null, null, n0_0, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                }
            });
            test("Should not add already existing node.", () {
                expect(graph.add(0, 0, 0, 2, null), false);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [null, null, null, null, n0_0, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                }
            });
            test("Should add all 3 children to outer node.", () {
                expect(graph.add(0, 2, -1, 3, 1), true);
                expect(graph.add(0, 2, 0, 4, 2), true);
                expect(graph.add(0, 2, 1, 3, 3), true);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var nn1_3 = graph.data.keys.firstWhere((node) => node.x == -1 && node.y == 3 && node.value == 1);
                var n0_4 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 4 && node.value == 2);
                var n1_3 = graph.data.keys.firstWhere((node) => node.x == 1 && node.y == 3 && node.value == 3);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [nn1_3, n0_4, n1_3, null, n0_0, null];
                var cn1_3exp = [null, null, null, null, null, n0_2];
                var c0_4exp = [null, null, null, null, n0_2, null];
                var c1_3exp = [null, null, null, n0_2, null, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                    expect(graph.data[nn1_3]![i], cn1_3exp[i]);
                    expect(graph.data[n0_4]![i], c0_4exp[i]);
                    expect(graph.data[n1_3]![i], c1_3exp[i]);
                }
            });
            test("Should add edge between 2 existing node and node values should not change.", () {
                expect(graph.add(-1, 3, 0, 4, null), true);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var nn1_3 = graph.data.keys.firstWhere((node) => node.x == -1 && node.y == 3 && node.value == 1);
                var n0_4 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 4 && node.value == 2);
                var n1_3 = graph.data.keys.firstWhere((node) => node.x == 1 && node.y == 3 && node.value == 3);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [nn1_3, n0_4, n1_3, null, n0_0, null];
                var cn1_3exp = [null, null, n0_4, null, null, n0_2];
                var c0_4exp = [null, null, null, nn1_3, n0_2, null];
                var c1_3exp = [null, null, null, n0_2, null, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                    expect(graph.data[nn1_3]![i], cn1_3exp[i]);
                    expect(graph.data[n0_4]![i], c0_4exp[i]);
                    expect(graph.data[n1_3]![i], c1_3exp[i]);
                }
            });
            test("Should not add side child, side parent, nor center parent of border node.", () {
                expect(graph.add(1, 3, 2, 4, null), false);
                expect(graph.add(1, 3, 2, 2, null), false);
                expect(graph.add(1, 3, 1, 1, null), false);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var nn1_3 = graph.data.keys.firstWhere((node) => node.x == -1 && node.y == 3 && node.value == 1);
                var n0_4 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 4 && node.value == 2);
                var n1_3 = graph.data.keys.firstWhere((node) => node.x == 1 && node.y == 3 && node.value == 3);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [nn1_3, n0_4, n1_3, null, n0_0, null];
                var cn1_3exp = [null, null, n0_4, null, null, n0_2];
                var c0_4exp = [null, null, null, nn1_3, n0_2, null];
                var c1_3exp = [null, null, null, n0_2, null, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                    expect(graph.data[nn1_3]![i], cn1_3exp[i]);
                    expect(graph.data[n0_4]![i], c0_4exp[i]);
                    expect(graph.data[n1_3]![i], c1_3exp[i]);
                }
            });
            test("Should not add side parent of outer node.", () {
                expect(graph.add(0, 2, -1, 1, null), false);
                var n0_0 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 0 && node.value == 0);
                var n0_2 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 2 && node.value == 5);
                var nn1_3 = graph.data.keys.firstWhere((node) => node.x == -1 && node.y == 3 && node.value == 1);
                var n0_4 = graph.data.keys.firstWhere((node) => node.x == 0 && node.y == 4 && node.value == 2);
                var n1_3 = graph.data.keys.firstWhere((node) => node.x == 1 && node.y == 3 && node.value == 3);
                var c0_0exp = [null, n0_2, null, null, null, null];
                var c0_2exp = [nn1_3, n0_4, n1_3, null, n0_0, null];
                var cn1_3exp = [null, null, n0_4, null, null, n0_2];
                var c0_4exp = [null, null, null, nn1_3, n0_2, null];
                var c1_3exp = [null, null, null, n0_2, null, null];
                for (int i = 0; i < 6; i++) {
                    expect(graph.data[n0_0]![i], c0_0exp[i]);
                    expect(graph.data[n0_2]![i], c0_2exp[i]);
                    expect(graph.data[nn1_3]![i], cn1_3exp[i]);
                    expect(graph.data[n0_4]![i], c0_4exp[i]);
                    expect(graph.data[n1_3]![i], c1_3exp[i]);
                }
            });
        });
    });
}
