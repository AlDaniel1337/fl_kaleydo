import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/course_player_view/course_player_view.dart';
import 'package:kaleydo/app/modules/courses/presentation/bindings/course_player_binding.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/views/franchise_detail_view.dart';
import 'package:kaleydo/app/modules/home/bindings/home_binding.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/bindings/franchise_detail_binding.dart';
import 'package:kaleydo/app/modules/home/views/home_view.dart';
import 'package:kaleydo/app/modules/media_player/views/media_player_view.dart';
import 'package:kaleydo/app/modules/media_player/bindings/media_player_binding.dart';
import 'package:kaleydo/app/modules/reader/presentation/views/reader_view.dart';
import 'package:kaleydo/app/modules/reader/presentation/bindings/reader_binding.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/courses_dashboard_view/courses_dashboard_view.dart';
import 'package:kaleydo/app/modules/courses/presentation/bindings/course_binding.dart';

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
   
    GetPage(
      name: CoursesDashboardView.route,
      page: () => const CoursesDashboardView(),
      binding: CourseBinding(),
    ),
   
    GetPage(
      name: CoursePlayerView.route,
      page: () => const CoursePlayerView(),
      binding: CoursePlayerBinding(),
    ),
  ];
}