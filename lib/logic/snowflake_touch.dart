import 'package:flutter/material.dart';
import 'package:snowflake/logic/snowflake.dart';
import 'package:snowflake/utils.dart';
import 'dart:math' as math;

void onTapSnowflake(double x, double y, Size size) {
    final sf = Snowflake();

    final next = sf.renderNext(size);
    for (final entry in next.edges.entries) {
        // screenEdge always has length 1 since we're only rendering next for 1 arm
        assert(entry.value.length == 1);

        if (inBuffer(entry.value.first, x, y)) {
            sf.add(entry.key.first.x, entry.key.first.y, entry.key.second.x, entry.key.second.y);
            return;
        }
    }

    final one = sf.renderOne(size);
    for (final entry in one.edges.entries) {
        // screenEdge always has length 1 since we're only rendering for 1 arm
        assert(entry.value.length == 1);

        if (inBuffer(entry.value.first, x, y)) {
            sf.remove(entry.key.first.x, entry.key.first.y, entry.key.second.x, entry.key.second.y);
            return;
        }
    }
}

bool inBuffer(Pair<Coordinate, Coordinate> edge, double x, double y) {
    final a1 = edge.first.x;
    final b1 = edge.first.y;
    final a2 = edge.second.x;
    final b2 = edge.second.y;
    final double c = math.sqrt((b2 - b1) * (b2 - b1) + (a2 - a1) * (a2 - a1)) / 5;

    if (a1 == a2) {
        // vertical edge
        return
            math.min(b1, b2) <= y && y <= math.max(b1, b2) &&
            a1 - c <= x && x <= a1 + c;
    } else if (b1 == b2) {
        // horizontal edge
        return
            b1 - c <= y && y <= b1 + c &&
            math.min(a1, a2) <= x && x <= math.max(a1, a2);
    } else {
        // diagonal edge
        final mPerp = -1 * (a2 - a1) / (b2 - b1); // slope of line perpendicular to edge
        final lPerp1 = mPerp * (x - a1) + b1;
        final lPerp2 = mPerp * (x - a2) + b2;
        // s, t, and u are values obtained from substituting y and then expanding
        // (x - a1)^2 + (y - a2)^2 = c^2 into quadratic form.
        final s = 1 + mPerp * mPerp; // 1 + mp^2
        final t = -2 * a1 * s; // -2(a1)(1 + mp^2)
        final u = a1 * a1 * s - c * c; // a1^2(1 + mp^2) - c^2
        final af1 = (-t + math.sqrt(t * t - 4 * s * u)) / (2 * s); // quadratic formula (+)
        final af2 = (-t - math.sqrt(t * t - 4 * s * u)) / (2 * s); // quadratic formula (-)
        final bf1 = mPerp * (af1 - a1) + b1;
        final bf2 = mPerp * (af2 - a1) + b1;
        final mPara = -1 / mPerp; // slope of line parallel to edge (aka slope of edge)
        final lPara1 = mPara * (x - af1) + bf1;
        final lPara2 = mPara * (x - af2) + bf2;
        return
            math.min(lPerp1, lPerp2) <= y && y <= math.max(lPerp1, lPerp2) &&
            math.min(lPara1, lPara2) <= y && y <= math.max(lPara1, lPara2);
    }
}
