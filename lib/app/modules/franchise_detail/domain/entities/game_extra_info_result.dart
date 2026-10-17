class GameExtraInfoResult {
  final String info;
  final List<String> tags;
  final List<String> images;
  final List<String> randomImages;
  final bool hasCGsGallery;

  GameExtraInfoResult({
    required this.info,
    required this.tags,
    required this.images,
    required this.randomImages,
    required this.hasCGsGallery,
  });

  factory GameExtraInfoResult.empty() => GameExtraInfoResult(
    info: '',
    tags: const [],
    images: const [],
    randomImages: const [],
    hasCGsGallery: false,
  );
}