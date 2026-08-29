import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kaleydo/app/modules/home/bindings/home_binding.dart';
import 'package:kaleydo/app/modules/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //: Inicializa los binarios nativos de libmpv
  MediaKit.ensureInitialized();
  
  //: Inicialización de ventana para Windows Desktop
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    center: true,
    backgroundColor: AppColors.background,
    skipTaskbar: false,
    title: 'Kaleydo',
  );
  
  //: Configuración de la ventana
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const KaleydoApp());
}

class KaleydoApp extends StatelessWidget {
  const KaleydoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kaleydo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialBinding: HomeBinding(),
      home: const HomeView(),
    );
  }
}