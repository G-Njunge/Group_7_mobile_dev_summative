import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// Shows the profile photo, or the person's initials if there is none.
class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 48,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: context.palette.brand,
      foregroundColor: context.palette.onBrand,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: hasPhoto
          ? null
          : Text(initialsOf(name), style: TextStyle(fontSize: radius * 0.6)),
    );
  }
}

/// "Amina Wanjiru" -> "AW", "Amina" -> "A", empty -> "?".
String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
