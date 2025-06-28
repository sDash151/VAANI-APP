import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoryGrid extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final void Function(BuildContext, int)? onItemTap;
  final String? appBarTitle;

  const CategoryGrid({
    Key? key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.appBarTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: appBarTitle != null
          ? AppBar(
              title: Text(appBarTitle!, style: textTheme.titleLarge),
              backgroundColor: colorScheme.background,
              elevation: 0,
              iconTheme: theme.iconTheme,
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return Animate(
              effects: [
                FadeEffect(duration: 500.ms, delay: (index * 80).ms),
                SlideEffect(
                    duration: 500.ms,
                    delay: (index * 80).ms,
                    begin: const Offset(0, 0.1)),
              ],
              child: _CategoryGridItem(
                title: items[index]['title'],
                icon: items[index]['icon'],
                onTap:
                    onItemTap != null ? () => onItemTap!(context, index) : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _CategoryGridItem({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
