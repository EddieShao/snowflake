import 'package:flutter/material.dart';
import 'components/snowflake_widget.dart';
import 'components/bottom_app_bar.dart' as bottom_app_bar;
import 'package:snowflake/theme.dart' as theme;

const double appBarHeight = 56;

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Snowflake',
            theme: theme.getTheme(),
            home: Scaffold(
                body: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints cons) {
                        return const MainPage();
                    },
                ),
            ),
        );
    }
}

class MainPage extends StatelessWidget {
    const MainPage({super.key});

    @override
    Widget build(BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        return Container(
            width: size.width,
            height: size.height,
            decoration: theme.getBackground(),
            child: Column(
                children: [
                    SizedBox(
                        width: size.width,
                        height: size.height - appBarHeight,
                        child: const SnowflakeWidget(),
                    ),
                    SizedBox(
                        width: size.width,
                        height: appBarHeight,
                        child: const bottom_app_bar.BottomAppBar(),
                    ),
                ],
            ),
        );
    }
}
