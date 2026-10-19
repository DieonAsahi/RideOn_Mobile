import 'package:flutter/material.dart';

const actionPopupMenuConstraints = BoxConstraints(
  minWidth: 140,
  maxWidth: 180,
);

const actionPopupMenuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

PopupMenuItem<T> actionPopupMenuItem<T>({
  required T value,
  required String label,
  required String iconAsset,
  required Color color,
}) {
  return PopupMenuItem<T>(
    value: value,
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          child: Image.asset(iconAsset, width: 20, height: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
