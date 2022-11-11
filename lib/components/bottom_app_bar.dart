import 'package:flutter/material.dart';
import 'package:snowflake/logic/snowflake.dart';
import 'package:snowflake/theme.dart' as theme;

class BottomAppBar extends StatelessWidget {
    const BottomAppBar({super.key});

    @override
    Widget build(BuildContext context) {
        return Row(
            children: [
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "Add an arm",
                    onPressed: () {
                        Snowflake().add(0, 6, 1, 5, 0);
                    },
                ),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: "Remove an arm",
                    onPressed: () {
                        Snowflake().remove(0, 6, 1, 5);
                    },
                ),
            ],
        );
    }
}
