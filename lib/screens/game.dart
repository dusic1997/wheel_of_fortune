import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:developer' as dev;
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:wheel_of_fortune/data/data.dart';

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Column(
        children: [
          Wrap(
            children: [
              ...tasks
                  .asMap()
                  .entries
                  .map((e) => Text('${e.key + 1} ${e.value}    '))
            ],
          ),
          const Stack(
            alignment: Alignment.center,
            children: [
              WheelWidget(),
              Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: RotatedBox(
                    quarterTurns: 3,
                    child: Icon(
                      Icons.arrow_right_alt,
                      size: 100,
                    )),
              )
            ],
          ),
        ],
      )),
    );
  }
}

class WheelWidget extends StatefulWidget {
  const WheelWidget({super.key});

  @override
  State<WheelWidget> createState() => _WheelWidgetState();
}

class _WheelWidgetState extends State<WheelWidget>
    with SingleTickerProviderStateMixin {
  final List<String> wheelSections = tasks;
  late AnimationController _animationController;
  double _rotationAngle = 0.0;

  // late AudioCache _audioCache;
  // late final AudioPlayer _player = AudioPlayer();
  // var assetSource = AssetSource('tick.mp3');

  ByteData? data;
  final _players = <AudioPlayer>[];
  late AudioPool? pool;
  init() async {
    pool = await FlameAudio.createPool(
      'tick.mp3',
      minPlayers: 1,
      maxPlayers: 1,
    );
  }

  void playTick() {
    if (pool == null) {
      FlameAudio.play('tick.mp3');
    } else {
      pool!.start();

      dev.log('pool!.start()');
    }
  }

  @override
  void initState() {
    super.initState();
    init();
    // _audioCache = AudioCache();
    // _audioCache.loadAsset('tick.mp3');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Adjust the duration as needed
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation completed, you can handle the result here
        // Calculate the prize based on the _rotationAngle
        // Display the prize or perform other actions
        // _animationController.reset();
      }
    });
  }

  var random = Random();
  bool playing = false;
  void _startSpinning() {
    _animationController.reset();
    _animationController.forward();

    var randomSurplusAnimationValue = random.nextDouble();
    var v0 = 2 * pi / 1;
    var a = v0 /
        ((1 + randomSurplusAnimationValue) *
            _animationController.duration!.inSeconds);
    Set rec = {};
    _animationController.addListener(() async {
      setState(() {
        var time = (_animationController.value *
            _animationController.duration!.inSeconds);
        _rotationAngle = v0 * time - 0.5 * a * time * time;
      });
      var d = _rotationAngle / (2 * pi / wheelSections.length);
      var truncateToDouble = d.truncateToDouble();
      if (_animationController.value > 0.0 &&
          _animationController.value < 1.0 &&
          (d - truncateToDouble) < 0.2) {
        if (rec.contains(truncateToDouble)) {
          return;
        }

        rec.add(truncateToDouble);
        dev.log('d=$d}');

        playTick();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    emptyPlayers();
    super.dispose();
  }

  void emptyPlayers() {
    for (var element in _players) {
      element.dispose();
    }
    _players.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Start the wheel spinning animation when tapped
        if (_animationController.value > 0 && _animationController.value < 1) {
          return;
        }
        emptyPlayers();
        _startSpinning();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAngle,
            child: SizedBox(
              width: 300.0,
              height: 300.0,
              child: CustomPaint(
                painter: WheelPainter(wheelSections.length),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final int numberOfSections;

  final List<String> sectionLabels;

  WheelPainter(this.numberOfSections)
      : sectionLabels =
            List.generate(numberOfSections, (index) => '${index + 1}');

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint paint = Paint();

    final double sectionAngle = 2 * pi / numberOfSections;

    // Colors for the wheel sections
    const List<Color> sectionColors = Colors.primaries;

    double startAngle = -pi / 2;

    for (int i = 0; i < numberOfSections; i++) {
      final double endAngle = startAngle + sectionAngle;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sectionAngle,
          false,
        )
        ..close();

      paint.color = sectionColors[i % sectionColors.length];
      canvas.drawPath(path, paint);

      // Calculate the position for the label
      final labelAngle = startAngle + sectionAngle / 2;
      final labelX = center.dx + radius * 0.7 * cos(labelAngle);
      final labelY = center.dy + radius * 0.7 * sin(labelAngle);
      final double midAngle =
          (startAngle + endAngle) / 2; // Middle angle of the section

      // Draw the label text
      final textPainter = TextPainter(
        text: TextSpan(
          text: sectionLabels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25.0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      // textPainter.paint(
      //     canvas,
      //     Offset(
      //         labelX - textPainter.width / 2, labelY - textPainter.height / 2));
      // Rotate the canvas to match the angle of the section
      canvas.save();
      canvas.translate(labelX, labelY);
      canvas.rotate(midAngle + pi / 2); // align text radially
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();

      startAngle = endAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
