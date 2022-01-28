import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaimon/gaimon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Expanded(
                        child: ListView(
                          // shrinkWrap: true,
                          children: [
                            TextButton(
                              onPressed: () => Gaimon.selection(),
                              child: const Text('👆 Selection'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.error(),
                              child: const Text('❌ Error'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.success(),
                              child: const Text('✅ Success'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.warning(),
                              child: const Text('🚨 Warning'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.heavy(),
                              child: const Text('💪 Heavy'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.medium(),
                              child: const Text('👊 Medium'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.light(),
                              child: const Text('🐥 Light'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.rigid(),
                              child: const Text('🔨 Rigid'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.soft(),
                              child: const Text('🧽 Soft'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patterns (iOS for now)',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final String response = await rootBundle
                                    .loadString('assets/haptics/rumble.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('📳 Rumble'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String response = await rootBundle
                                    .loadString('assets/haptics/heartbeats.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('💗 Heartbeat'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String response = await rootBundle
                                    .loadString('assets/haptics/gravel.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('🪨 Gravel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String response = await rootBundle
                                    .loadString('assets/haptics/inflate.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('😮‍💨 Inflate'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
