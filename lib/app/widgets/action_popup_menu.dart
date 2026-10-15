import 'package:flutter/material.dart';

const actionPopupMenuConstraints = BoxConstraints(
  minWidth: 288,
  maxWidth: 288,
);

const actionPopupMenuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
);

PopupMenuItem<T> actionPopupMenuItem<T>({
  required T value,
  required String label,
  required String iconAsset,
  required Color color,
}) {
  return PopupMenuItem<T>(
    value: value,
    height: 106,
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: SizedBox(
      width: 208,
      child: Row(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            child: Image.asset(iconAsset, width: 32, height: 32),
          ),
          const SizedBox(width: 28),
          Text(
            label,
            style: TextStyle(
              fontSize: 26,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}
