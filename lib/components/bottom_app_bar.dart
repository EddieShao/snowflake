import 'package:flutter/material.dart';
import 'package:snowflake/logic/snowflake.dart';

class BottomAppBar extends StatelessWidget {
    final bool editSnowflake;
    final void Function(bool edit) updateEditSnowflake;

    const BottomAppBar(this.editSnowflake, this.updateEditSnowflake, {super.key});

    @override
    Widget build(BuildContext context) {
        final sf = Snowflake();
        return Row(
            children: [
                IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "Add an arm",
                    onPressed: () {
                        sf.add(0, 6, 1, 5, 0);
                    },
                ),
                IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: "Remove an arm",
                    onPressed: () {
                        sf.remove(0, 6, 1, 5);
                    },
                ),
                IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: "Show next available arms",
                    onPressed: () {
                        updateEditSnowflake(!editSnowflake);
                    },
                ),
            ],
        );
    }
}
