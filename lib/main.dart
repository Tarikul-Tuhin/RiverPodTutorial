import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// *********************************** Web Socket *****************************************

abstract class WebsocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    // counter will start from a given integar by user.
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}
// abstract class WebSocketClient {
//   Stream<int> getCounterStream();
// }

// class FakeWebSocketClient implements WebSocketClient {
//   @override
//   Stream<int> getCounterStream() async* {
//     int i = 0;
//     while (true) {
//       await Future.delayed(const Duration(milliseconds: 500));
//       yield i++;
//     }
//   }
// }

final websocketClinetProvider = Provider<WebsocketClient>((ref) {
  return FakeWebsocketClient();
});

// *********************************** Web Socket *****************************************

// final counterProvider = StateProvider.autoDispose((ref) => 0); // if we would like to dispose the app automatically through riverpod
// final counterProvider = StreamProvider<int>((ref) {
//   final wsClinet = ref.watch(websocketClinetProvider);
//   return wsClinet.getCounterStream();
// });

final counterProvider = StreamProvider.family<int, int>((ref, start) {
  final wsClinet = ref.watch(websocketClinetProvider);
  return wsClinet.getCounterStream(start);
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
              surface: const Color(0xff003909))),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Counter Page'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const CounterPage()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(
        counterProvider(5)); // counter will start from a given integar by user.
    // *********************************************** Showing Popup while counter>=5 by using ref.listen ******************************
    // ref.listen<int>(counterProvider, ((previous, next) {
    //   // ref.listen is not as same as ref.watch. ref.listen works after a widget gets rebuild. but watch runs with builds
    //   if (next >= 5) {
    //     showDialog(
    //       context: context,
    //       builder: (context) {
    //         return AlertDialog(
    //           title: const Text('Warning'),
    //           content: const Text(
    //               'Counter dangerously high. Consider resetting it.'),
    //           actions: [
    //             TextButton(
    //               onPressed: () {
    //                 Navigator.of(context).pop();
    //               },
    //               child: Text('OK'),
    //             )
    //           ],
    //         );
    //       },
    //     );
    //   }
    // }));
    // *********************************************** Showing Popup while counter>=5 by using ref.listen ******************************
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
              onPressed: () {
                ref.invalidate(counterProvider);
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Text(
          counter
              .when(
                  data: (int value) => value,
                  error: (Object e, _) => e,
                  loading: () => 5)
              .toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       ref.read(counterProvider.notifier).state++;
      //     },
      //     child: const Icon(Icons.add)),
    );
  }
}
