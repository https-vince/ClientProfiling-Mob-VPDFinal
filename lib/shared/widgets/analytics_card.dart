import 'package:flutter/material.dart';
import 'tap_scale_wrapper.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  // kept for API compatibility — no longer used as fill color
  final Color backgroundColor;
  /// Optional tap callback — when provided, a press-scale animation is applied.
  final VoidCallback? onTap;

  const AnalyticsCard({
    Key? key,
    required this.title,
    required this.value,
    this.backgroundColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return TapScaleWrapper(onTap: onTap, child: card);
    }
    return card;
  }
}