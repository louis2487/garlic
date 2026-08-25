import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:garlic/app_router.dart';
import 'package:garlic/model/services/network.dart';
import 'package:garlic/view_model/garlic_vm.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  Network();
  runApp(const GarlicApp());
}

class GarlicApp extends StatelessWidget {
  const GarlicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GarlicVM()),
      ],
      child: const AppRouter(),
    );
  }
}
