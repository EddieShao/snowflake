import 'package:flutter/material.dart';
import 'package:snowflake/logic/snowflake.dart';
import 'package:snowflake/theme.dart' as theme;

class BottomAppBar extends StatelessWidget {
    const BottomAppBar({super.key});

    @override
    Widget build(BuildContext context) {
        return Center(
            child: IconButton(
                icon: const Icon(Icons.add),
                tooltip: "Add center arm",
                onPressed: () {
                    Snowflake().add(0, 2, -1, 3);
                },
            ),
        );
    }
}
