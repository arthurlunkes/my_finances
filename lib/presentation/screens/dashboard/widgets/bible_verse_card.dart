import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/bible_verses.dart';

class BibleVerseCard extends StatelessWidget {
  final BibleVerse verse;

  const BibleVerseCard({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.tithe.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.tithe.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.tithe.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: AppColors.tithe,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Versículo do Dia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.tithe,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${verse.text}"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${verse.reference}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.tithe,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
