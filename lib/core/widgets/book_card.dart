import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String imageUrl;
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
    this.width = 130,
    this.height = 180,
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
              child: Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
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
          const SizedBox(height: 8),
          SizedBox(
            width: width,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
