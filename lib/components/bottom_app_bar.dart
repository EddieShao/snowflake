import 'package:flutter/material.dart';
import 'package:snowflake/theme.dart' as theme;

class BottomAppBar extends StatelessWidget {
    const BottomAppBar({super.key});

    @override
    Widget build(BuildContext context) {
        return DecoratedBox(
            decoration: BoxDecoration(color: theme.white.withOpacity(0.1)),
            child: const Center(child: Text("Navigation Bar"),),
        );
    }
}
