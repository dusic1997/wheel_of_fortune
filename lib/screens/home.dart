import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wheel_of_fortune/screens/game.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('幸运转盘'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(CupertinoPageRoute(builder: (ctx) => const Game()));
            },
            child: const Text('开始游戏')),
      ),
    );
  }
}
