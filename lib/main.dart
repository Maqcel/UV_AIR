import 'package:UV_AIR/sensor.dart';
import 'package:UV_AIR/value_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ValueProvider()),
        ],
        child: SensorScreen(),
      ),
    );
  }
}
