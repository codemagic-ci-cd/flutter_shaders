import 'dart:ui';
import 'package:vector_math/vector_math_64.dart' as vec;
import 'package:flutter/material.dart';

const shaderfilename = "seascape.frag";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shaders',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _startTime = 0;
  double get _elapsedTimeInSeconds => (DateTime.now().millisecondsSinceEpoch - _startTime) / 1000;

  double seaHeight = 0.5;

  @override
  Widget build(BuildContext context) {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder<FragmentShader>(
                  future: _load(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final shader = snapshot.data!;
                      shader
                        ..setFloat(1, MediaQuery.of(context).size.width) //width
                        ..setFloat(2, MediaQuery.of(context).size.height); //height

                      return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            shader.setFloat(0, _elapsedTimeInSeconds);
                            return CustomPaint(
                              painter: ShaderPainter(shader),
                            );
                          });
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width, size.height);
    canvas.rotate(180 * vec.degrees2Radians);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

Future<FragmentShader> _load() async {
  FragmentProgram program = await FragmentProgram.fromAsset('shaders/$shaderfilename');
  final shader = program.fragmentShader();

  return shader;
}
