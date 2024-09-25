import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uor_find_manager/view/splash_view.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        textTheme:  const TextTheme(bodyLarge: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            bodyMedium:  TextStyle(color: Colors.white)),
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}
