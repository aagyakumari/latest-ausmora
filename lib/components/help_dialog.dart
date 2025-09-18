import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  final List<Map<String, String>> helpItems;
  final String title;

  const HelpDialog({
    Key? key,
    required this.helpItems,
    this.title = 'How to fill this form',
  }) : super(key: key);

  static Future<void> show(BuildContext context, List<Map<String, String>> helpItems, {String title = 'How to fill this form'}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => HelpDialog(helpItems: helpItems, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final dialogWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.9;
    final dialogMaxHeight = isTablet ? screenHeight * 0.7 : screenHeight * 0.6;
    final titleFontSize = isTablet ? 22.0 : 18.0;
    final contentFontSize = isTablet ? 18.0 : 15.0;
    final buttonFontSize = isTablet ? 18.0 : 15.0;
    final padding = isTablet ? 28.0 : 18.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? screenWidth * 0.18 : screenWidth * 0.05,
        vertical: isTablet ? 40 : 24,
      ),
      child: Center(
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(
            maxHeight: dialogMaxHeight,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 254, 254, 254),
            border: Border.all(color: Color(0xFFFF9933), width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: Color(0xFFFF9933), size: titleFontSize + 2),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFFFF9933),
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black54, size: titleFontSize),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(color: Color(0xFFFF9933), thickness: 1),
              SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: helpItems.map((item) => _buildHelpItem(item['title'] ?? '', item['description'] ?? '', contentFontSize)).toList(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFFFF9933),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Got it!', style: TextStyle(fontSize: buttonFontSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String description, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9933),
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }
} 