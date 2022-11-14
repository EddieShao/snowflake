import 'package:flutter/material.dart';

const white = Colors.white;
const black = Color(0xFF181818);
const navy = Color(0xFF203060);
const purple = Color(0xFF584880);
const lightBlue = Color(0xFF65C2F5);
const blue = Color(0xFF09B1EC);
const magenta = Color(0xFFB958A5);
const pink = Color(0xFFFF5677);
const orange = Color(0xFFFD841F);
const brown = Color(0xFF9A3D0A);
const yellow = Colors.yellow;

ThemeData getTheme() {
    return ThemeData(
        textTheme: const TextTheme(
            bodyText1: TextStyle(color: white),
            bodyText2: TextStyle(color: white),
        )
    );
}

BoxDecoration getBackground() {
    List<Color> gradColors = [black, black];

    _execByTime(
        sunrise: () => gradColors = [orange, pink],
        day: () => gradColors = [blue, lightBlue],
        sunset: () => gradColors = [magenta, pink],
        night: () => gradColors = [navy, purple],
    );

    return BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradColors
        ),
    );
}

Color getEditEdgeColor() {
    Color color = black;
    _execByTime(
        sunrise: () => color = brown,
        day: () => color = brown,
        sunset: () => color = yellow,
        night: () => color = lightBlue,
    );
    return color;
}

void _execByTime({
    void Function()? day,
    void Function()? night,
    void Function()? sunset,
    void Function()? sunrise
}) {
    int hour = DateTime.now().hour;
    if (hour >= 6 && hour < 9) {
        // sunrise
        sunrise?.call();
    } else if (hour >= 9 && hour < 18) {
        // day
        day?.call();
    } else if (hour >= 18 && hour < 21) {
        // sunset
        sunset?.call();
    } else {
        // night
        night?.call();
    }
}
