import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/custom_button.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail(String feedback) async {
    final String subject = Uri.encodeComponent('App Support Feedback');
    final String body = Uri.encodeComponent(feedback);
    final Uri emailUri = Uri.parse(
        'mailto:aagyakumari565@gmail.com?subject=$subject&body=$body');

    setState(() => _isSending = true);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);

      // 🟧 Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Opening email app...',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFFF9933),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait before navigating back
      Future.delayed(const Duration(seconds: 3), () async {
        setState(() => _isSending = false);

        final box = Hive.box('settings');
        final guestProfile = await box.get('guest_profile');

        if (guestProfile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLogoPage()),
          );
        }
      });
    } else {
      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleSubmit() {
    final feedback = _feedbackController.text.trim();

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _sendEmail(feedback);
  }

  Future<void> _navigateBack() async {
    final box = Hive.box('settings');
    final guestProfile = await box.get('guest_profile');

    if (guestProfile != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLogoPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        await _navigateBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopNavBar(
                title: 'Support',
                onLeftButtonPressed: _navigateBack,
                onRightButtonPressed: () {},
                leftIcon: Icons.arrow_back,
                rightIcon: Icons.help_outline,
              ),
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Image.asset(
                  'assets/images/support.png',
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Enter your feedback or issues here...',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              CustomButton(
                buttonText: _isSending ? 'Sending...' : 'Submit',
  onPressed: _isSending ? () {} : _handleSubmit, // 👈 always non-null
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          currentPageIndex: null,
        ),
      ),
    );
  }
}
