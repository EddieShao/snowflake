import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snowflake/app_state.dart';
import 'components/snowflake_widget.dart';
import 'components/bottom_app_bar.dart' as bottom_app_bar;
import 'package:snowflake/theme.dart' as theme;

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

class MainPage extends StatelessWidget {
    const MainPage({super.key});
    
    @override
    Widget build(BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        return Container(
            width: size.width,
            height: size.height,
            decoration: theme.getBackground(),
            child: MultiProvider(
                providers: [
                    ChangeNotifierProvider(create: (context) => EditState(false),),
                    ChangeNotifierProvider(create:(context) => DoneState(false),),
                ],
                child: Stack(
                    children: [
                        SizedBox(
                            width: size.width,
                            height: size.height,
                            child: const SnowflakeWidget(),
                        ),
                        Positioned(
                            bottom: 0,
                            child: SizedBox(
                                width: size.width,
                                height: appBarHeight,
                                child: const bottom_app_bar.BottomAppBar(),
                            ),
                        )
                    ],
                ),
            ),
        );
    }
}
