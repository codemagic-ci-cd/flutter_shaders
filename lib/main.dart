import 'dart:ui';

import 'package:flutter/material.dart';

const shaderfilename = "animated_gradient.frag";

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
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _startTime = 0;
  double get _elapsedTimeInSeconds => (_startTime - DateTime.now().millisecondsSinceEpoch) / 1000;

  @override
  Widget build(BuildContext context) {
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
                      _startTime = DateTime.now().millisecondsSinceEpoch;
                      shader.setFloat(1, MediaQuery.of(context).size.width); //width
                      shader.setFloat(2, MediaQuery.of(context).size.height); //height
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
