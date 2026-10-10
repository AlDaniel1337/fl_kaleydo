class FolderOption {
  final String name;
  bool isSelected;
  bool hasMultipleContents;
  bool createExtraFolder;
  bool createCGSFolder;
  bool createImagesFolder;

  FolderOption({
    required this.name, 
    this.isSelected          = false, 
    this.hasMultipleContents = false,
    this.createExtraFolder   = false,
    this.createCGSFolder     = false,
    this.createImagesFolder  = false,
  });
}