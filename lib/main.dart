import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Face Detection",
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightBlue)),
      home: const MyHomePage(title: 'Face Detection POC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _permissionHandel() async {
    final isCameraPermissionGranted = await Permission.camera.isGranted;
    if (!isCameraPermissionGranted) {
      await Permission.camera.request();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission granted ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _permissionHandel();
            },
            tooltip: 'Permission request',
            child: const Icon(Icons.perm_camera_mic),
          ),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Camera button',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
