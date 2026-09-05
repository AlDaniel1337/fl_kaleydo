// lib/app/data/services/library_state_service.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LibraryStateService extends GetxService {
  late final GetStorage _box;

  static const _kFavorites = 'user_favorites';
  static const _kInProcess = 'user_in_process';

  final RxSet<String> favoritePaths  = <String>{}.obs;
  final RxSet<String> inProcessPaths = <String>{}.obs;

  /// Inicializa la caja de almacenamiento y carga los estados guardados
  Future<LibraryStateService> init() async {
    _box = GetStorage();
    
    final savedFavs = _box.read<List<dynamic>>(_kFavorites) ?? [];
    favoritePaths.assignAll(savedFavs.cast<String>());

    final savedProc = _box.read<List<dynamic>>(_kInProcess) ?? [];
    inProcessPaths.assignAll(savedProc.cast<String>());

    return this;
  }

  //: Favoritos
  /// Marca o desmarca un video como favorito
  void toggleFavorite(String path) {
    if (favoritePaths.contains(path)) {
      favoritePaths.remove(path);
    } else {
      favoritePaths.add(path);
    }
    _box.write(_kFavorites, favoritePaths.toList());
  }

  bool isFavorite(String path) => favoritePaths.contains(path);



  //: En proceso
  /// Marca o desmarca un video como "en proceso" 
  /// + Por ejemplo si el usuario está viendo un video y quiere marcarlo para continuar más tarde.
  void toggleInProcess(String path) {
    if (inProcessPaths.contains(path)) {
      inProcessPaths.remove(path);
    } else {
      inProcessPaths.add(path);
    }
    _box.write(_kInProcess, inProcessPaths.toList());
  }

  bool isInProcess(String path) => inProcessPaths.contains(path);
}