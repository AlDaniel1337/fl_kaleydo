abstract class FolderRepository {
  Future<void> createDirectory(String path);
  Future<bool> directoryExists(String path);
  Future<void> createFile(String path);
  Future<bool> fileExists(String path);
}