import 'package:test/test.dart';
import 'package:snowflake/utils.dart';

void main() {
    group("Pair", () {
        group("operator ==", () {
            test("Same reference should be equal.", () {
                const p = Pair(0, 0);
                const copy = p;
                expect(p == copy, true);
            });
            test("Same values should be equal.", () {
                const p1 = Pair("hello", "world");
                const p2 = Pair("hello", "world");
                expect(p1 == p2, true);
            });
            test("Same values and different order should be equal.", () {
                const p1 = Pair(3, 5);
                const p2 = Pair(5, 3);
                expect(p1 == p2, true);
            });
            test("Different values should not be equal.", () {
                const p1 = Pair(0, 2);
                const p2 = Pair(3, 4);
                expect(p1 == p2, false);
            });
        });
    });
    group("IterableHelper", () {
        group("find()", () {
            test("Should return null when item not found.", () {
                final empty = <int>[];
                final l = [1, 2, 3, 4, 5];
                expect(empty.find((e) => true), null);
                expect(l.find((e) => e == 6), null);
            });
            test("Should return value found.", () {
                final l = [null, 2, 3, null, null];
                final found = l.find((e) => e != null);
                expect(found == 2 || found == 3, true);
            });
        });
        group("mapIndexed()", () {
            test("Should not do anything to empty list.", () {
                final empty = <int>[];
                expect(empty.mapIndexed((e, i) => null).length, 0);
            });
            test("Should map and keep order of input list.", () {
                final l = [0, 1, 2, 3, 4];
                final lNew = l.mapIndexed((e, i) => e + 1);
                for (int i = 0; i < l.length; i++) {
                    expect(lNew.elementAt(i), l[i] + 1);
                }
            });
        });
    });
}
