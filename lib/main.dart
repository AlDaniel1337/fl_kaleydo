import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaleydo/app/config/routes/app_pages.dart';
import 'package:media_kit/media_kit.dart';
import 'app/data/data.models.index.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //: Inicialización de almacenamiento local
  await GetStorage.init();
  await Get.putAsync(() => PlayerStorageService().init());
  await Get.putAsync<LibraryStateService>(() => LibraryStateService().init());
  

  //: Inicializa los binarios nativos de libmpv
  MediaKit.ensureInitialized();
  
  //: Inicialización de ventana para Windows Desktop
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 600),
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
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}