import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page2.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/offer/model/offer_model.dart';

class OfferWidget extends StatefulWidget {
  final Offer? offer;
  final bool tappable;

  const OfferWidget({super.key, this.offer, this.tappable = true});

  @override
  _OfferWidgetState createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.offer == null) {
      return _buildNoBundleContainer(screenWidth);
    }

    return widget.tappable
        ? GestureDetector(
            onTap: _handleTap,
            child: _buildOfferContainer(screenWidth, screenHeight),
          )
        : _buildOfferContainer(screenWidth, screenHeight);
  }

  void _handleTap() {
    if (widget.offer == null) return;

    Widget destinationPage;
    switch (widget.offer!.categoryTypeId) {
      case 1:
        destinationPage = HoroscopePage(showBundleQuestions: true);
        break;
      case 2:
        destinationPage = CompatibilityPage2(showBundleQuestions: true);
        break;
      case 3:
        destinationPage = AuspiciousTimePage(showBundleQuestions: true);
        break;
      default:
        destinationPage = DashboardPage();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destinationPage),
    );
  }

  Widget _buildNoBundleContainer(double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9933),
          width: 1.5,
        ),
        color: Colors.white,
      ),
      child: const Center(
        child: Text(
          'No bundles available at the moment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferContainer(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section (smaller height)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: widget.offer?.imageData != null
                ? Image.memory(
                    widget.offer!.imageData!,
                    width: double.infinity,
                    height: screenHeight * 0.15, // 👈 reduced height
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: screenHeight * 0.13,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),

          // Text content
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer?.question ?? 'No Question Available',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // 👈 slightly smaller
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  "Rs ${widget.offer?.price.toStringAsFixed(0) ?? '0'}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                if (widget.offer?.priceBeforeDiscount != null)
                  Text(
                    "Rs ${widget.offer!.priceBeforeDiscount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
