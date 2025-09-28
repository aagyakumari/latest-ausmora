import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';

class ProfileCardDialog extends StatelessWidget {
  final ProfileModel profile;

  const ProfileCardDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    final borderColor = const Color(0xFFFF9933);
    final labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: borderColor,
      fontSize: isLargeScreen ? 20 : 16,
    );
    final valueStyle = TextStyle(
      fontSize: isLargeScreen ? 18 : 14,
      color: Colors.black,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 80 : 24, vertical: 24),
      child: Center(
        child: Container(
          width: isLargeScreen ? screenSize.width * 0.5 : double.infinity,
          padding: EdgeInsets.all(isLargeScreen ? 32 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_circle, color: borderColor, size: isLargeScreen ? 40 : 32),
                  SizedBox(width: 12),
                  Text('User Profile', style: TextStyle(
                    fontSize: isLargeScreen ? 24 : 18,
                    fontWeight: FontWeight.w600,
                    color: borderColor,
                  )),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[700]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextRow('Name', profile.name, labelStyle, valueStyle),
              _buildTextRow('Gender', profile.gender, labelStyle, valueStyle),
              _buildTextRow('Date of Birth', profile.dob, labelStyle, valueStyle),
              _buildTextRow(
                'Place of Birth',
                _formatPlaceOfBirth(profile),
                labelStyle, valueStyle),
              _buildTextRow('Time of Birth', profile.tob, labelStyle, valueStyle),
              _buildTextRow('Time zone', profile.tz.toString(), labelStyle, valueStyle),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: borderColor,
                    textStyle: TextStyle(fontSize: isLargeScreen ? 18 : 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: valueStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatPlaceOfBirth(ProfileModel profile) {
    if (profile.city != null) {
      final city = profile.city!;
      if (city.cityAscii.isNotEmpty && city.country.isNotEmpty) {
        return '${city.cityAscii}, ${city.country}';
      } else if (city.cityAscii.isNotEmpty) {
        return city.cityAscii;
      } else if (city.country.isNotEmpty) {
        return city.country;
      }
    }
    // fallback to cityId if city is null
    return profile.cityId.isNotEmpty ? profile.cityId : 'Unknown';
  }
} 