abstract class FolderRepository {
  Future<void> createDirectory(String path);
  Future<bool> directoryExists(String path);
}