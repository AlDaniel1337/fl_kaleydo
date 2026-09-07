import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';
import 'components/components.index.dart';

class ChapterGridDialog extends StatelessWidget {

  final ReaderController controller;

  const ChapterGridDialog({
    super.key, 
    required this.controller
  });

  static void show(BuildContext context, ReaderController controller) {
    Get.dialog(
      ChapterGridDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(

        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //: Header del diálogo
            DialogHeader(controller: controller),

            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 8),

            //: Grid de páginas
            DialogGrid(controller: controller),
          ],
        ),
      ),
    );
  }
}



class DialogGrid extends StatelessWidget {
  const DialogGrid({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: controller.imagePaths.length,
        itemBuilder: (context, index) {
          final pageNum = index + 1;
          return Obx(() {
            
            final isCurrent = controller.currentPage.value == pageNum;

            return InkWell(
              onTap: () {
                controller.jumpToPage(pageNum);
                Get.back();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? AppColors.primaryAccent : AppColors.cardBorder,
                    width: isCurrent ? 2.5 : 1,
                  ),
                  color: Colors.black54,
                ),
                clipBehavior: Clip.antiAlias,

                child: GridImageItem(
                  imagePath: controller.imagePaths[index],
                  pageNum: pageNum, 
                  isCurrent: isCurrent
                ),
              ),
            );
          });
        },
      ),
    );
  }
}