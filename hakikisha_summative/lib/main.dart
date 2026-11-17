import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'features/auth/presentation/pages/landing_page.dart';
import 'firebase_options.dart';

// get_it setup and go_router are added once M5's core lands.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HakikishaApp());
}

class HakikishaApp extends StatelessWidget {
  const HakikishaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hakikisha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F3D1E)),
      ),
      // Temporary: the AuthGate (M1) / go_router (M5) picks the first screen later.
      home: const LandingPage(),
    );
  }
}
