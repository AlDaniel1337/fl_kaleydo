import 'package:flutter/material.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/components.index.dart';

class GameWrapView extends StatelessWidget {

  final List<FranchiseItemModel> items;
  final bool isNovel;
  final Function(String) launchExecutable;
   
  const GameWrapView({
    super.key,
    required this.items,
    required this.isNovel,
    required this.launchExecutable,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 20,
          runSpacing: 20,

          children: items.map((item) {
            return SizedBox(
              width: 250,
              height: 450,
              child: GameCard(
                game: item,
                isNovel: isNovel,
                launchExecutable: (executablePath) => launchExecutable(executablePath),
              ),
            );
          }).toList(),

        ),
      ),
    );
  }
}