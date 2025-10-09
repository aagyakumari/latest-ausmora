import 'dart:convert';
import 'dart:typed_data';

class Offer {
  final String id;
  final String question;
  final String? imageBlob;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final bool active;
  final double price;
  final double priceBeforeDiscount;
  final double discountAmount;
  final bool isBundle;
  final String questionCategoryId;
  final int? categoryTypeId;

  Offer({
    required this.id,
    required this.question,
    this.imageBlob,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.active,
    required this.price,
    required this.priceBeforeDiscount,
    required this.discountAmount,
    required this.isBundle,
    required this.questionCategoryId,
    this.categoryTypeId,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] ?? '',
      question: json['question'] ?? 'Unknown Question',
      imageBlob: json['image_blob'] ?? '',
      effectiveFrom: DateTime.tryParse(json['effective_from'] ?? '') ?? DateTime(2000, 1, 1),
      effectiveTo: DateTime.tryParse(json['effective_to'] ?? '') ?? DateTime(2000, 1, 1),
      active: json['active'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      priceBeforeDiscount: (json['price_before_discount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      isBundle: json['is_bundle'] ?? false,
      questionCategoryId: json['question_category_id'] ?? '',
      categoryTypeId: json['category_type_id'] != null
          ? int.tryParse(json['category_type_id'].toString())
          : null,
    );
  }

  /// ✅ Safely converts Base64 or raw data URLs to bytes
  Uint8List? get imageData {
    if (imageBlob == null || imageBlob!.isEmpty) return null;

    try {
      // Remove potential "data:image/png;base64," prefix if present
      final cleaned = imageBlob!
          .replaceAll(RegExp(r'data:image/[^;]+;base64,'), '')
          .trim();

      // Decode safely, even if padded or malformed slightly
      return base64Decode(cleaned);
    } catch (e) {
      print('⚠️ Error decoding image for offer $id: $e');
      return null;
    }
  }
}
