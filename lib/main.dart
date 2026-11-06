import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC19nIGfXiH-ooPIe1SJXyXRoVHzYCRJEY",
      authDomain: "flutter-demo-7e830.firebaseapp.com",
      databaseURL: "https://flutter-demo-7e830-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "flutter-demo-7e830",
      storageBucket: "flutter-demo-7e830.firebasestorage.app",
      messagingSenderId: "604918799984",
      appId: "1:604918799984:web:17be47559907b46a305eb5",
      measurementId: "G-1NJ5N7SJJN",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final FirebaseDatabase rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://flutter-demo-7e830-default-rtdb.europe-west1.firebasedatabase.app/',
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 0, 158, 145),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Log In / Sign Up'),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  Future<void> _push_data() async {
    if (_nameController.text.isEmpty ||
        _specialtyController.text.isEmpty ||
        _yearController.text.isEmpty) {
      return;
    }
    try {
      await MyApp.rtdb.ref('users').push().set({
        'name': _nameController.text,
        'specialty': _specialtyController.text,
        'year': _yearController.text,
      });

      _nameController.clear();
      _specialtyController.clear();
      _yearController.clear();
    } catch (e) {
      return;
    }
  }

  @override
  void dispose() {
    // очищаем память при закрытии экрана
    _nameController.dispose();
    _specialtyController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Flexible(
              child: Text(
                widget.title,
                // overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 24),
            const Flexible(child: _Auth()),
          ],
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              const SizedBox(height: 40.0),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Специальность',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Год выпуска',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _push_data,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Сохранить анкету',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const Expanded(child: _MyHomeDataUserBlock()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyHomeDataUserBlock extends StatelessWidget {
  const _MyHomeDataUserBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: MyApp.rtdb.ref('users').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('Нет данных'));
        }

        final rawData = snapshot.data!.snapshot.value as Map;
        final list = rawData.entries.toList();
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final userData = list[index].value as Map;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  'ФИО: ${userData['name'] ?? 'Информация отсутствует'}',
                ),
                subtitle: Text(
                  'Специальность: ${userData['specialty'] ?? 'Информация отсутствует'} \n Год выпуска: ${userData['year'] ?? 'Информация отсутствует'}г',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Auth extends StatelessWidget {
  const _Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        return TextButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final cred = await FirebaseAuth.instance.signInWithPopup(
              GoogleAuthProvider(),
            );
            messenger.showSnackBar(
              SnackBar(content: Text('Вы вошли в аккаунт ${cred.user?.email}')),
            );
          },
          child: const Text('Войти через Google'),
        );
      },
    );
  }
}
