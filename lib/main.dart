import 'package:flutter/material.dart';
import 'package:life_counter/life_event.dart';
import 'package:life_counter/objectbox.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LifeCounterPage(),
    );
  }
}

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({Key? key}) : super(key: key);

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  Store? store;
  Box<LifeEvent>? lifeEventBox;
  List<LifeEvent> lifeEvents = [];

  Future<void> initialize() async {
    store = await openStore();
    lifeEventBox = store?.box<LifeEvent>();
    fetchLifeEvents();
  }

  void fetchLifeEvents() {
    lifeEvents = lifeEventBox?.getAll() ?? [];
    setState(() {});
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('本当に削除しますか？'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('すべて削除されますが本当によろしいですか?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('はい'),
              onPressed: () {
                lifeEventBox?.removeAll();
                fetchLifeEvents();
              },
            ),
            TextButton(
              child: const Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人生カウンター'),
        actions: [
          IconButton(
            onPressed: () {
              _showMyDialog();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: lifeEvents.length,
        itemBuilder: (context, index) {
          final lifeEvent = lifeEvents[index];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  lifeEvent.title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                )),
                Text(
                  '${lifeEvent.count}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    lifeEvent.count++;
                    lifeEventBox?.put(lifeEvent);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.plus_one),
                ),
                IconButton(
                  onPressed: () {
                    lifeEvent.count--;
                    lifeEventBox?.put(lifeEvent);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.exposure_minus_1),
                ),
                IconButton(
                  onPressed: () {
                    lifeEventBox?.remove(lifeEvent.id);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ); // まずはTextを表示するだけにします。
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final newLifeEvent = await Navigator.of(context).push<LifeEvent>(
              MaterialPageRoute(
                builder: (context) {
                  return const AddLifeEventPage();
                },
              ),
            );
            if (newLifeEvent != null) {
              lifeEventBox?.put(newLifeEvent);
              fetchLifeEvents();
            }
          }),
    );
  }
}

class AddLifeEventPage extends StatefulWidget {
  const AddLifeEventPage({Key? key}) : super(key: key);

  @override
  State<AddLifeEventPage> createState() => _AddLifeEventPageState();
}

class _AddLifeEventPageState extends State<AddLifeEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ライフイベント追加'),
      ),
      body: TextFormField(
        onFieldSubmitted: (text) {
          final lifeEvent = LifeEvent(title: text, count: 0); // インスタンス作成
          Navigator.of(context).pop(lifeEvent); // 前のページにインスタンスを渡します
        },
      ),
    );
  }
}
