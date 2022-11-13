import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snowflake/app_state.dart';
import 'package:snowflake/logic/snowflake.dart';

class BottomAppBar extends StatelessWidget {
    const BottomAppBar({super.key});

    @override
    Widget build(BuildContext context) {
        final sf = Snowflake();
        return Row(
            children: [
                Consumer<EditState>(
                    builder: (context, editState, child) {
                        return IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: "Add an arm",
                            onPressed: () {
                                if (sf.add(0, 6, 1, 5, 0)) {
                                    editState.force();
                                }
                            },
                        );
                    },
                ),
                Consumer<EditState>(
                    builder: (context, editState, child) {
                        return IconButton(
                            icon: const Icon(Icons.remove),
                            tooltip: "Remove an arm",
                            onPressed: () {
                                if (sf.remove(0, 6, 1, 5)) {
                                    editState.force();
                                }
                            },
                        );
                    },
                ),
                Consumer<EditState>(
                    builder: (context, editState, child) {
                        return IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: "Show next available arms",
                            onPressed: () {
                                editState.value = !editState.value;
                            },
                        );
                    },
                ),
                Consumer<DoneState>(
                    builder: (context, doneState, child) {
                        return IconButton(
                            icon: const Icon(Icons.done),
                            tooltip: "Finish building snowflake",
                            onPressed: () {
                                doneState.value = !doneState.value;
                            },
                        );
                    },
                ),
            ],
        );
    }
}
