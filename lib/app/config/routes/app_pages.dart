import 'package:get/get.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/franchise_detail_view.dart';
import 'package:kaleydo/app/modules/home/bindings/home_binding.dart';
import 'package:kaleydo/app/modules/franchise_detail/bindings/franchise_detail_binding.dart';
import 'package:kaleydo/app/modules/home/views/home_view.dart';
import 'package:kaleydo/app/modules/media_player/views/media_player_view.dart';
import 'package:kaleydo/app/modules/media_player/bindings/media_player_binding.dart';
import 'package:kaleydo/app/modules/reader/views/reader_view.dart';
import 'package:kaleydo/app/modules/reader/bindings/reader_binding.dart';

class AppPages {
  static const initial = HomeView.route;

  static final routes = [
    GetPage(
      name: HomeView.route,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: FranchiseDetailView.route,
      page: () => const FranchiseDetailView(),
      binding: FranchiseDetailBinding(),
    ),
    GetPage(
      name: MediaPlayerView.route,
      page: () => const MediaPlayerView(),
      binding: MediaPlayerBinding(),
    ),
    GetPage(
      name: ReaderView.route,
      page: () => const ReaderView(),
      binding: ReaderBinding(),
    ),
  ];
}