import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add more theme customizations here
      ),
      initialBinding: InitialBinding(),
      initialRoute: '/splash',
      getPages: AppPages.routes,
      // Optional: Set up localization, environment configurations, etc.
    );
  }
}