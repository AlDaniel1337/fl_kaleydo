import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_local_data_source.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource localDataSource;

  FolderRepositoryImpl(this.localDataSource);

  @override
  Future<void> createDirectory(String path) => localDataSource.createDirectory(path);

  @override
  Future<bool> directoryExists(String path) => localDataSource.directoryExists(path);
}