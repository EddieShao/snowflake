import 'package:flutter/material.dart';

const white = Colors.white;
const navy = Color(0xFF203060);
const purple = Color(0xFF584880);
const lightBlue = Color(0xFFC4F2FF);

ThemeData getTheme() {
    return ThemeData(
        textTheme: const TextTheme(
            bodyText1: TextStyle(color: white),
            bodyText2: TextStyle(color: white),
        )
    );
}

BoxDecoration getBackground() {
    return const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [navy, purple]
        ),
    );
}

Color getEditEdgeColor() {
    return lightBlue;
}
