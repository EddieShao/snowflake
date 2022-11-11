import 'package:test/test.dart';
import 'package:snowflake/utils.dart';

void main() {
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
