import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? author;
  final double width;
  final double height;
  final double elevation;
  final double borderRadius;
  final double fontSize;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.author,
    this.width = 130,
    this.height = 210,
    this.elevation = 4,
    this.borderRadius = 20,
    this.fontSize = 15,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Material(
            elevation: elevation,
            borderRadius: BorderRadius.circular(borderRadius),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.asset(
                'assets/coverImages/$imageUrl',
                width: width,
                height: height - 25,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.blueAccent,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (author != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    author!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize - 4,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
