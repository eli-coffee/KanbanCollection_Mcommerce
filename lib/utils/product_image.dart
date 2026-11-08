import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/product_service.dart';

Widget buildProductImage(String url,
    {double? height, double? width, BoxFit fit = BoxFit.cover}) {
  Widget broken() => Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image),
      );

  if (url.isEmpty) return broken();

  // Photo picked from the device, stored as a base64 string
  if (url.startsWith('data:image')) {
    try {
      return Image.memory(base64Decode(url.split(',').last),
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => broken());
    } catch (_) {
      return broken();
    }
  }

  // Older products that still point to assets/images
  return Image.asset(ProductService.assetPath(url),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => broken());
}