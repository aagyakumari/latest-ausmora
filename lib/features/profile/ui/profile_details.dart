import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/features/sign_up/repo/sign_up_repo.dart';
import 'package:flutter_application_1/features/updateprofile/update_profile_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  bool _isLoading = true;
  bool _isEditing = false;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _guestProfileData;
    String? selectedCity;
  String? selectedCountry;
  String? selectedLng;
  late String selectedTzId;
  late String selectedTzName;
  late String selectedCityId;
  late double selectedTzValue;
  List<Map<String, String>> citySuggestions = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  final TextEditingController _tzController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();


  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
  try {
    final box = Hive.box('settings');
    String? token = await box.get('token');
    String url = '$baseApiUrl/Guests/Get';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['error_code'] == "0") {
        setState(() {
          _profileData = responseData['data']['item'];
          _guestProfileData = _profileData!['guest_profile'];

          // Save guest_profile to Hive
          box.put('guest_profile', _guestProfileData);

          _nameController.text = _profileData!['name'] ?? '';
          _dobController.text = _profileData!['dob'] ?? '';
          _tobController.text = _profileData!['tob'] ?? '';
          _genderController.text = _profileData!['gender'] ?? '';

          // ✅ Extract city name & country
          var cityData = _profileData!['city'];
          if (cityData != null) {
            _locationController.text = "${cityData['city_ascii']}, ${cityData['country']}";
          } else {
            _locationController.text = "Unknown City";
          }

          // ✅ Safely convert tz to String before assigning
          _tzController.text = _profileData!['tz']?.toString() ?? '';
          // var tzData = _profileData!['tz']?.toString() ?? '';

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to load profile data';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
    });
  }
}


 // Update Profile Function
// Update Profile Function
void _updateProfile() async {
  final updateProfileService = UpdateProfileService();

  // ✅ Use selectedCityId (from Autocomplete) instead of fetching from the text field
  String cityId = selectedCityId; 

  // If cityId is empty, show an error message
  if (cityId.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid city selection. Please choose a valid city.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // ✅ Use selectedTzValue (from Autocomplete) instead of parsing from the text field
  double tzValue = selectedTzValue; 

  // Ensure the TZ value is valid, if not, set to default (0.0)
  if (tzValue == 0.0) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid time zone selection. Please choose a valid time zone.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Call the update profile service with the correct values
  bool success = await updateProfileService.updateProfile(
    _nameController.text,
    cityId, // ✅ Use cityId instead of city name
    _dobController.text, 
    _tobController.text,
    tzValue,
    _genderController.text, // ✅ Use selectedTzValue for time zone
  );

  if (success) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Color(0xFFFF9933),
      ),
    );
    _fetchProfileData();
    setState(() {
      _isEditing = false;
    });
  } else {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to update profile. Please try again.'),
      ),
    );
  }
}


// Date Picker Function
Future<void> _selectDate(BuildContext context) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );
  if (picked != null) {
    setState(() {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }
}

// Time Picker Function
Future<void> _selectTime(BuildContext context) async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (picked != null) {
    setState(() {
      _tobController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }
}

Future<String?> _getCityId(String cityName) async {
  final url = Uri.parse('$baseApiUrl/Guests/SearchCity?search_param=$cityName');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      
      if (data.isNotEmpty) {
        return data.first["id"].toString(); // ✅ Get the first matching city ID
      }
    }
  } catch (e) {
    print("Error fetching city ID: $e");
  }

  return null; // Return null if no match found
}


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double padding = screenWidth * 0.05; // 5% of screen width
    final double spacing = screenHeight * 0.02; // 2% of screen height
    final double fontSize = screenWidth * 0.04; // 4% of screen width
    final double buttonPadding = screenWidth * 0.1; // 10% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF9933),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Text(_errorMessage!,
                                style: TextStyle(
                                    color: Colors.red, fontSize: fontSize)),
                          )
                        : _buildProfileUI(
                            fontSize, spacing, screenWidth, padding),
                SizedBox(height: screenHeight * 0.1), // Extra space for buttons
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, double fontSize) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9933),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        ),
      ),
    );
  }

Widget _buildProfileUI(double fontSize, double spacing, double screenWidth, double padding) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Name', _nameController, Icons.person, _isEditing, fontSize),
        SizedBox(height: spacing),

         _buildTextField('Gender', _genderController, Icons.person, _isEditing, fontSize),
        SizedBox(height: spacing), 

        // Conditionally display City selection field when editing
        _isEditing
            ? _buildCitySelectionField(controller: _locationController)
            : _buildTextField('City Name', _locationController, Icons.location_city, _isEditing, fontSize),
        SizedBox(height: spacing),

        _buildTextField('Date of Birth (YYYY-MM-DD)', _dobController, Icons.cake, _isEditing, fontSize,
            onTap: () => _selectDate(context)),
        SizedBox(height: spacing),

        _buildTextField('Time of Birth (HH:mm)', _tobController, Icons.access_time, _isEditing, fontSize,
            onTap: () => _selectTime(context)),
        SizedBox(height: spacing),

        // Conditionally display Time Zone selection field when editing
        _isEditing
            ? _buildTzSelectionField(controller: _tzController)
            : _buildTextField('Time Zone', _tzController, Icons.access_time_filled, _isEditing, fontSize),
        SizedBox(height: spacing * 1.5),

        _isEditing
            ? _buildButton('Update Profile', _updateProfile, fontSize)
            : _buildButton(
                'Edit Profile',
                () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                fontSize,
              ),

        SizedBox(height: spacing * 1.5),

        _guestProfileData == null
            ? Center(
                child: Text('Profile is being generated...',
                    style: TextStyle(color: Colors.orange, fontSize: fontSize)),
              )
            : _buildGuestProfileUI(fontSize, spacing, screenWidth),

        SizedBox(height: spacing * 1.5),
      ],
    ),
  );
}

Widget _buildCitySelectionField({
  required TextEditingController controller,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double fontSize = screenWidth * 0.03;

  return Padding(
    padding: EdgeInsets.symmetric(
      // horizontal: screenWidth * 0.05,
      // vertical: screenHeight * 0.015,
    ),
    child: Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _debounceFetchCities(textEditingValue.text);
      },
      onSelected: (String selection) {
        final selected = citySuggestions.firstWhere(
          (element) =>
              "${element['city']}, ${element['country']}" == selection,
          orElse: () => {},
        );

        setState(() {
          selectedCity = selected["city"] ?? "";
          selectedCountry = selected["country"] ?? "";
          selectedLng = selected["lat"] ?? "0.0";
          selectedCityId = selected["id"] ?? "";
        });
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onEditingComplete) {
        return TextFormField(
  controller: fieldController,
  focusNode: focusNode,
  onEditingComplete: onEditingComplete,
  decoration: InputDecoration(
    labelText: "City Name",
    prefixIcon: Icon(Icons.location_city),
    labelStyle: TextStyle(fontSize: fontSize),
    hintText: _locationController.text,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFFF9933)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFFF9933)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFFF9933)),
    ),
  ),
  style: TextStyle(fontSize: fontSize),
);

      },
    ),
  );
}


// Debounce function to reduce API calls
Timer? _debounce;
Future<List<String>> _debounceFetchCities(String query) async {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  final completer = Completer<List<String>>();
  
  _debounce = Timer(Duration(milliseconds: 500), () async {
    citySuggestions = await fetchCities(query);
    completer.complete(citySuggestions.map((e) => "${e['city']}, ${e['country']}").toList());
  });

  return completer.future;
}

Widget _buildTzSelectionField({
  required TextEditingController controller,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double fontSize = screenWidth * 0.03;

  return Padding(
    padding: EdgeInsets.symmetric(
      // horizontal: screenWidth * 0.05,
      // vertical: screenHeight * 0.015,
    ),
    child: FutureBuilder<List<Map<String, String>>>(
      future: fetchTz(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tzSuggestions = snapshot.data!;

        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }

            return tzSuggestions
                .map((e) => e['name']!)
                .where((tz) => tz
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            final selected = tzSuggestions.firstWhere(
              (element) => element['name'] == selection,
              orElse: () => {},
            );

            setState(() {
              selectedTzId = selected["id"] ?? "";
              selectedTzName = selected["name"] ?? "";
              selectedTzValue = double.tryParse(selectedTzId) ?? 0.0;
              _tzController.text = selectedTzValue.toString();
            });

            print("Selected TZ Value: $selectedTzValue");
          },
          fieldViewBuilder:
              (context, fieldController, focusNode, onEditingComplete) {
            return TextFormField(
  controller: fieldController,
  focusNode: focusNode,
  onEditingComplete: onEditingComplete,
  decoration: InputDecoration(
    labelText: "Time Zone",
    prefixIcon: Icon(Icons.access_time),
    labelStyle: TextStyle(fontSize: fontSize),
    hintText: _tzController.text,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFFF9933)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFFF9933)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFFF9933)),
    ),
  ),
  style: TextStyle(fontSize: fontSize),
)
;
          },
        );
      },
    ),
  );
}



  Widget _buildGuestProfileUI(
      double fontSize, double spacing, double screenWidth) {
    final guest = _guestProfileData!;
    final accent = const Color(0xFFFF9933);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accent, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: spacing),
      padding: EdgeInsets.all(spacing * 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin, color: accent, size: fontSize * 1.3),
              SizedBox(width: 8),
              Text(
                'Guest Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 1.2,
                  color: accent,
                ),
              ),
              Expanded(
                child: Divider(
                  color: accent.withOpacity(0.3),
                  thickness: 1,
                  indent: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // Basic Description (expandable)
          _buildGuestProfileDetailRow(
            icon: Icons.info_outline,
            label: 'Description',
            value: guest['basic_description'] ?? '',
            fontSize: fontSize,
            isExpandable: true,
            screenWidth: screenWidth,
          ),
          SizedBox(height: spacing * 0.7),

          // Lucky Color
          Row(
            children: [
              Icon(Icons.color_lens, color: accent, size: fontSize * 1.1),
              SizedBox(width: 8),
              Text('Lucky Color:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
              SizedBox(width: 8),
              Container(
                width: fontSize * 1.2,
                height: fontSize * 1.2,
                decoration: BoxDecoration(
                  color: _parseColor(guest['lucky_color']),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.5)),
                ),
              ),
              SizedBox(width: 8),
              Text(guest['lucky_color'] ?? '', style: TextStyle(fontSize: fontSize)),
            ],
          ),
          SizedBox(height: spacing * 0.7),

          // Lucky Gem
          Row(
            children: [
              Icon(Icons.diamond, color: accent, size: fontSize * 1.1),
              SizedBox(width: 8),
              Text('Lucky Gem:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
              SizedBox(width: 8),
              Text(guest['lucky_gem'] ?? '', style: TextStyle(fontSize: fontSize)),
            ],
          ),
          SizedBox(height: spacing * 0.7),

          // Lucky Number
          Row(
            children: [
              Icon(Icons.star, color: accent, size: fontSize * 1.1),
              SizedBox(width: 8),
              Text('Lucky Number:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
              SizedBox(width: 8),
              Chip(
                label: Text(guest['lucky_number'] ?? '', style: TextStyle(color: Colors.white)),
                backgroundColor: accent,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
            ],
          ),
          SizedBox(height: spacing * 0.7),

          // Rashi Name
          Row(
            children: [
              Icon(Icons.brightness_5, color: accent, size: fontSize * 1.1),
              SizedBox(width: 8),
              Text('Rashi:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
              SizedBox(width: 8),
              Text(guest['rashi_name'] ?? '', style: TextStyle(fontSize: fontSize)),
            ],
          ),
          SizedBox(height: spacing * 0.7),

          // Compatibility
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.favorite, color: accent, size: fontSize * 1.1),
              SizedBox(width: 8),
              Text('Compatibility:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  guest['compatibility_description'] ?? '',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for color parsing
  Color _parseColor(String? colorName) {
    if (colorName == null) return Colors.grey;
    final colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'black': Colors.black,
      'white': Colors.white,
      'grey': Colors.grey,
      'gray': Colors.grey,
      // Add more as needed
    };
    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }

  // Expandable description row
  Widget _buildGuestProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required double fontSize,
    bool isExpandable = false,
    double? screenWidth,
  }) {
    const int maxLength = 100;
    bool isTruncated = value.length > maxLength && !_isExpanded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFFF9933), size: fontSize * 1.1),
            SizedBox(width: 8),
            Text('$label:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                isTruncated ? '${value.substring(0, maxLength)}...' : value,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ],
        ),
        if (value.length > maxLength)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: fontSize * 0.2, left: 32),
              child: Text(
                _isExpanded ? 'View Less' : 'View More',
                style: TextStyle(color: const Color(0xFFFF9933), fontSize: fontSize),
              ),
            ),
          ),
      ],
    );
  }

Widget _buildTextField(
  String label,
  TextEditingController controller,
  IconData icon,
  bool isEnabled,
  double fontSize, {
  void Function()? onTap, // Add an optional onTap parameter
}) {
  return TextFormField(
    controller: controller,
    enabled: isEnabled,
    readOnly: onTap != null, // Make field read-only if onTap is provided
    onTap: onTap, // Assign the onTap logic
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      labelStyle: TextStyle(fontSize: fontSize),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide:
            const BorderSide(color: Color(0xFFFF9933)), // Set border color
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
            color: Color(0xFFFF9933)), // Set border color for enabled state
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
            color: Color(0xFFFF9933)), // Set border color for focused state
      ),
    ),
  );
}
}
