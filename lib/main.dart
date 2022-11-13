import 'package:flutter/material.dart';
import 'components/snowflake_widget.dart';
import 'components/bottom_app_bar.dart' as bottom_app_bar;
import 'package:snowflake/theme.dart' as theme;
import 'package:snowflake/logic/snowflake.dart';

const double appBarHeight = 56;

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

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

class MainPage extends StatefulWidget {
    const MainPage({super.key});
    
    @override
    State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
    late final AnimationController spin = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

    final showNextSnowflakeEdges = ValueNotifier(false);

    @override
    void initState() {
        super.initState();

        // TODO: replace hard-coded stuff with DB access
        Snowflake()
            ..clear()
            ..add(0, 0, 0, 2, 0)
            ..add(0, 2, -1, 3, 0)
            ..add(-1, 3, -1, 5, 0)
            ..add(-1, 5, 0, 6, 0)
            ..add(0, 6, 1, 5, 0)
            ..add(0, 6, -1, 7, 0)
            ..add(0, 6, 1, 7, 0)
            ..add(0, 6, 0, 8, 0)
            ..add(0, 6, 0, 4, 0);
    }

    @override
    Widget build(BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        return Container(
            width: size.width,
            height: size.height,
            decoration: theme.getBackground(),
            child: ValueListenableBuilder<bool>(
                valueListenable: showNextSnowflakeEdges,
                builder: (context, value, child) {
                    return Stack(
                        children: [
                            SizedBox(
                                width: size.width,
                                height: size.height,
                                child: SnowflakeWidget(showNextSnowflakeEdges, spin),
                            ),
                            Positioned(
                                bottom: 0,
                                child: SizedBox(
                                    width: size.width,
                                    height: appBarHeight,
                                    child: bottom_app_bar.BottomAppBar(showNextSnowflakeEdges),
                                ),
                            )
                        ],
                    );
                },
            )
        );
    }
}
