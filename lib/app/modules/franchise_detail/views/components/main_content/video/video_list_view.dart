import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';

class VideoListView extends StatelessWidget {

  final ScrollController controller;
  final List<FranchiseItemModel> episodes;
  final Function(int) onEpisodeTap;
   
  const VideoListView({
    super.key, 
    required this.controller, 
    required this.episodes,
    required this.onEpisodeTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: episodes.length,
      itemBuilder: (ctx, idx) => Card(
        color: AppColors.cardBackground,
        margin: const EdgeInsets.only(bottom: 8),

        child: ListTile(
          leading: const Icon(Icons.play_circle_fill, color: AppColors.primaryAccent),
          title: Text(episodes[idx].title, style: const TextStyle(color: AppColors.textPrimary)),
          subtitle: Text(episodes[idx].seasonName ?? 'Anime',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onEpisodeTap(idx);
          },
        ),
      ),

    );
  }
}