import 'package:get/get.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/franchise_detail_view.dart';
import 'package:kaleydo/app/modules/home/bindings/home_binding.dart';
import 'package:kaleydo/app/modules/franchise_detail/bindings/franchise_detail_binding.dart';
import 'package:kaleydo/app/modules/home/views/home_view.dart';

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
  ];
}