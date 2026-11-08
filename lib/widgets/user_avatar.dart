import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final String name;

  const UserAvatar({super.key, required this.radius, required this.name});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AuthService().photo,
      builder: (_, b64, _) {
        ImageProvider? image;
        if (b64 != null && b64.isNotEmpty) {
          try {
            image = MemoryImage(base64Decode(b64));
          } catch (_) {
            image = null;
          }
        }
        return CircleAvatar(
          radius: radius,
          backgroundImage: image,
          child: image == null
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(fontSize: radius * 0.8),
                )
              : null,
        );
      },
    );
  }
}