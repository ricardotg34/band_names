import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';

import 'package:band_names/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SocketService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Band Names App',
        initialRoute: 'home',
        theme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue.shade900,
            accentColor: Colors.blueAccent,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Colors.blueAccent)),
        routes: {'home': (_) => HomePage()},
      ),
    );
  }
}
