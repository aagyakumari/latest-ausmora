import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/buildcirclewithname.dart';
import 'package:flutter_application_1/components/categorydropdown.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/components/zodiac.utils.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/features/ask_a_question/model/question_model.dart';
import 'package:flutter_application_1/features/ask_a_question/repo/ask_a_question_repo.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/features/profile/repo/profile_repo.dart';
import 'package:flutter_application_1/features/sign_up/repo/sign_up_repo.dart';
import 'package:flutter_application_1/features/support/ui/support_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/components/profile_card_dialog.dart';

class CompatibilityPage2 extends StatefulWidget {
  final bool showBundleQuestions;
  const CompatibilityPage2({super.key, required this.showBundleQuestions});


  @override
  _CompatibilityPage2State createState() => _CompatibilityPage2State();
}

class _CompatibilityPage2State extends State<CompatibilityPage2> {
  final Color primaryColor = const Color(0xFFFF9933);
  ProfileModel? _profile;
  Map<String, dynamic>? _compatibilityData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _person2Name = 'Person 2'; // Variable to store Person 2's name
  late Future<List<Question>>
      _questionsFuture; // Future for Horoscope questions
  final AskQuestionRepository _askQuestionRepository =
      AskQuestionRepository(); // Instantiate the repository
  String? _editedName = ProfileRepo().getName();
  String? _editedGender = ProfileRepo().getGender();
  String? _editedDob = '';
  String? _editedCityId = '';
  String? _editedTob = '';
  bool isEditing = false;
  String? _editedCityName = '';
  String? _editedTz = '';
  String? selectedCity;
  String? selectedCountry;
  String? selectedLng;
  String selectedTzId = '';
  String selectedTzName = '';
  double selectedTzValue = 0.0;
  String selectedCityId = '';
  List<Map<String, String>> citySuggestions = [];

  // Separate selections for Profile 2
  String? selectedCity2;
  String? selectedCountry2;
  String? selectedLng2;
  String selectedTzId2 = '';
  String selectedTzName2 = '';
  double selectedTzValue2 = 0.0;
  String selectedCityId2 = '';

  String? _editedName2 = '';
  String? _editedGender2 = '';
  String? _editedDob2 = '';
  String? _editedCityId2 = '';
  String? _editedTob2 = '';
  bool isEditing2 = false;
  String? _editedCityName2 = '';
  String? _editedTz2 = '';

  Color _iconColor = Colors.black; // Initial color

//For editable dialog 1
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController cityIdController = TextEditingController();
  final TextEditingController tobController = TextEditingController();
  final TextEditingController tzController = TextEditingController();
  final TextEditingController genderController = TextEditingController();


  //For editable dialog 2
  final TextEditingController name2Controller = TextEditingController();
  final TextEditingController dob2Controller = TextEditingController();
  final TextEditingController cityId2Controller = TextEditingController();
  final TextEditingController tob2Controller = TextEditingController();
  final TextEditingController tz2Controller = TextEditingController();
  final TextEditingController gender2Controller = TextEditingController();


  void _updateIconColor() {
    setState(() {
      _iconColor =
          _iconColor == Colors.black ? const Color(0xFFFF9933) : Colors.black;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    if (widget.showBundleQuestions) {
      _questionsFuture = _askQuestionRepository.fetchBundleQuestionsByTypeId(2);
    } else {
      _questionsFuture = _askQuestionRepository.fetchQuestionsByTypeId(2);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditableProfileDialog2(context);
    });
  }

   Future<void> _fetchProfileData() async {
  try {
    print("Fetching profile data...");

    final box = Hive.box('settings');
    String? token = await box.get('token');
    if (token == null) {
      print("Token not found.");
      return;
    }

    String url = '$baseApiUrl/Guests/Get';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

            print('response data :$responseData');
      String errorCode = responseData['error_code'] ?? -1;


      if (errorCode == "0" && responseData['data'] != null) {
        print('WWW: ${responseData.toString()}');
        setState(() {
          _profile = ProfileModel.fromJson(responseData['data']?['item']?? {});
           _compatibilityData = responseData['data']['compatibility'];
            _isLoading = false;
          
        });
        print("Profile loaded: ${_profile?.name}");
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Unknown error';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to load data. Status: ${response.statusCode}';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Error: $e';
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TopNavBar(
                    title: 'Specific Compatibility',
                    onLeftButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompatibilityPage()),
                      );
                    },
                    onRightButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SupportPage()),
                      );
                    },
                    leftIcon: Icons.arrow_back, // Icon for the left side
                    rightIcon: Icons.help, // Icon for the right side
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circle and Name for Profile 1
                      Column(
                        children: [
                             CircleWithNameWidget(
                                assetPath: (_editedDob != null &&
                                        _editedDob!.toString().isNotEmpty)
                                    ? getZodiacImage(getZodiacSign(
                                        _editedDob!)) // ✅ Use `_editedDob`
                                    : (_profile?.dob != null
                                        ? getZodiacImage(getZodiacSign(
                                            _profile!.dob.toString()))
                                        : 'assets/signs/default.png'), // Fallback image
                                name: _editedName ??
                                    _profile?.name ??
                                    'no name available',
                                screenWidth: screenWidth,
                                onTap: () {
                                  if (_profile?.name != null) {
                                    _showProfileDialog(_profile!);
                                  } else {
                                    print("no name");
                                  }
                                },
                                primaryColor: const Color(0xFFFF9933),
                              ),
                          const SizedBox(
                              height: 8), // Space between name and 'Edit' text
                          GestureDetector(
                            onTap: () {
                              _showEditableProfileDialog(
                                  context); // Function for the first profile
                            },
                            child: const Text(
                              'Edit', // 'Edit' text below the name
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFF9933),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      // Circle and Name for Profile 2
                      Column(
                        children: [
                          CircleWithNameWidget(
                            assetPath:  'assets/signs/default.png', // Fallback image
                            name: _person2Name!,
                            screenWidth: screenWidth,
                            onTap: () {
                              _showEditableProfileDialog2(
                                  context); // Function for the second profile
                            },
                            primaryColor: isEditing2
                                ? const Color(0xFFFF9933)
                                : const Color.fromARGB(255, 110, 110, 109),
                          ),
                          const SizedBox(
                              height: 8), // Space between name and 'Edit' text
                          GestureDetector(
                            onTap: () {
                              _showEditableProfileDialog2(
                                  context); // Function for the second profile
                            },
                            child: const Text(
                              'Edit', // 'Edit' text below the name
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFF9933),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Center(
                    child: Text(
                      'Choose Compatibility Questions',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w100,
                        color: const Color.fromARGB(255, 87, 86, 86),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show a loading indicator while fetching data
                        : CategoryDropdown(
                            // onTap: () => null,
                            inquiryType: 'compatibility',
                            categoryTypeId: 2,
                            onQuestionsFetched: (categoryId, questions) {
                              // Handle fetched questions
                            },
                            editedProfile2:
                                isEditing2 ? getEditedProfile2() : null,
                            editedProfile:
                                isEditing ? getEditedProfile() : null,
                                  showBundleQuestions: widget.showBundleQuestions, // Pass the flag

                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          currentPageIndex: 1),
    );
  }

 void _showProfileDialog(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) => ProfileCardDialog(profile: profile),
    );
  }

  void _showEditableProfileDialog(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: _editedName);
    final TextEditingController genderController =
        TextEditingController(text: _editedGender);
    final TextEditingController dobController =
        TextEditingController(text: _editedDob);
    final TextEditingController cityIdController =
        TextEditingController(text: _editedCityId);
    final TextEditingController tobController =
        TextEditingController(text: _editedTob);
    final TextEditingController tzController =
        TextEditingController(text: _editedTz?.toString() ?? '');

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Check Horoscope for:',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width *
                0.035, // Adjusting font size based on screen width
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFF9933),
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
                  children: [
                    Expanded(child:_buildTextField(
                    'Name', nameController, 'This field required', context)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(child:_buildTextField(
                    'Gender', genderController, 'This field required', context)),
                  ]
                
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            dobController.text = "${pickedDate.toLocal()}"
                                .split(' ')[0]; // Format as yyyy-mm-dd
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildTextField('Date of Birth', dobController,
                              'Please select a date', context),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            tobController.text =
                                pickedTime.format(context); // Format time
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildTextField('Time of Birth', tobController,
                              'Please select a time', context),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildCitySelectionField(controller: cityIdController, isProfile2: false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                FutureBuilder<List<Map<String, String>>>(
                  future: fetchTz(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final tzSuggestions = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: tzSuggestions.any((tz) => tz["id"] == selectedTzId) ? selectedTzId : null,
                      items: tzSuggestions.map((tz) => DropdownMenuItem<String>(
                        value: tz["id"],
                        child: Text(tz["name"] ?? ""),
                      )).toList(),
                      onChanged: (String? newValue) {
                        final selected = tzSuggestions.firstWhere((tz) => tz["id"] == newValue, orElse: () => {});
                        setState(() {
                          selectedTzId = selected["id"] ?? "";
                          selectedTzName = selected["name"] ?? "";
                          selectedTzValue = double.tryParse(selectedTzId) ?? 0.0;
                          _editedTz = selectedTzValue.toString();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Time Zone",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space buttons apart
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height *
                          0.01, // Responsive vertical padding
                      horizontal: MediaQuery.of(context).size.width *
                          0.04, // Responsive horizontal padding
                    ),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color.fromARGB(255, 219, 35, 35),
                    fontSize: MediaQuery.of(context).size.width *
                        0.04, // Responsive font size
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  isEditing = true;
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      _editedName = nameController.text;
                      _editedDob = dobController.text;
                      _editedCityId = cityIdController.text;
                      _editedTob = convertTo24HourFormat(tobController.text);
                      _editedTz = selectedTzValue.toString();
                      _editedGender = genderController.text;
                    });

                    print('Edited Name: $_editedName');
                    print('Edited Date of Birth: $_editedDob');
                    print('Edited City ID: $_editedCityId');
                    print('Edited Time of Birth: $_editedTob');
                    print('Edited Time zone: $_editedTz');
                    print('Edited Gender: $_editedGender');

                    Navigator.of(context).pop();
                  }
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height *
                          0.01, // Responsive vertical padding
                      horizontal: MediaQuery.of(context).size.width *
                          0.04, // Responsive horizontal padding
                    ),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: MediaQuery.of(context).size.width *
                        0.04, // Responsive font size
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String convertTo24HourFormat(String time12hr) {
    // Trim leading and trailing whitespaces from the input string
    time12hr = time12hr.trim();

    // Split the time string into the time and the period (AM/PM)
    List<String> parts = time12hr.split(' ');

    if (parts.length != 2) {
      return '00:00'; // Return default value in case of invalid input
    }

    String timePart = parts[0]; // e.g., "7:21"
    String period = parts[1]; // e.g., "AM" or "PM"

    // Split the timePart into hour and minute
    List<String> timeParts = timePart.split(':');
    if (timeParts.length != 2) {
      return '00:00'; // Return default value in case of invalid format
    }

    int hour = int.parse(timeParts[0]); // Get the hour
    int minute = int.parse(timeParts[1]); // Get the minute

    // Convert to 24-hour format based on AM/PM
    if (period == 'AM' || period == 'am') {
      if (hour == 12) {
        hour = 0; // Convert "12 AM" to "00:00"
      }
    } else if (period == 'PM' || period == 'pm') {
      if (hour != 12) {
        hour += 12; // Convert "1 PM" to "13", "2 PM" to "14", etc.
      }
    } else {
      return '00:00'; // Return default value if AM/PM is invalid
    }

    // Format the hour and minute to ensure two digits for hour and minute
    String hourString = hour.toString().padLeft(2, '0');
    String minuteString = minute.toString().padLeft(2, '0');

    // Return the formatted 24-hour time
    return '$hourString:$minuteString';
  }

  Map<String, dynamic> getEditedProfile() {
    return {
      'name': _editedName,
      'dob': _editedDob,
      'city_id': selectedCityId,
      'tob': _editedTob, // Default to an empty string if null
      'tz': selectedTzValue.toString(),
      'gender': _editedGender
    };
  }

   Widget _buildTextField(String label, TextEditingController controller, String validationMessage, BuildContext context) {
  // Using MediaQuery to adjust padding, font size and width dynamically
  double screenWidth = MediaQuery.of(context).size.width;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: const Color.fromARGB(255, 87, 86, 86),
          fontSize: screenWidth * 0.03, // Dynamic font size
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(height: screenWidth * 0.02), // Adjusted space based on screen size
      SizedBox(
        width: screenWidth * 0.8, // Adjust width of text field based on screen size
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '', // Keep hint text minimal
            contentPadding: EdgeInsets.symmetric(vertical: screenWidth * 0.02, horizontal: screenWidth * 0.03), // Adjust padding dynamically
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFFF9933), width: 1),
            ),
          ),
          style: TextStyle(fontSize: screenWidth * 0.03), // Adjust font size dynamically
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            if (label.contains('Date of Birth') && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
              return 'Please enter date in yyyy-mm-dd format';
            }
            return null;
          },
        ),
      ),
      SizedBox(height: screenWidth * 0.04), // Adjust space after text field
    ],
  );
  }

  void _showEditableProfileDialog2(BuildContext context) {
  final TextEditingController name2Controller = TextEditingController(text: _editedName2);
  final TextEditingController gender2Controller = TextEditingController(text: _editedGender2);
  final TextEditingController dob2Controller = TextEditingController(text: _editedDob2);
  final TextEditingController cityId2Controller = TextEditingController(text: _editedCityId2);
  final TextEditingController tob2Controller = TextEditingController(text: _editedTob2);
  final TextEditingController tz2Controller = TextEditingController(text: _editedTz2?.toString() ?? '');






  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Check Compatibility with:',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.035, // Adjusting font size based on screen width
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF9933),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  children: [
                    Expanded(child:_buildTextField(
                    'Name', name2Controller, 'This field required', context)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(child:_buildTextField(
                    'Gender', gender2Controller, 'This field required', context)),
                  ]
                
                ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          dob2Controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format as yyyy-mm-dd
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildTextField('Date of Birth', dob2Controller, 'Please select a date', context),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          tob2Controller.text = pickedTime.format(context); // Format time
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildTextField('Time of Birth', tob2Controller, 'Please select a time', context),
                      ),
                    ),
                  ),
                ],
              ),
                 _buildCitySelectionField(controller: cityId2Controller, isProfile2: true),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                FutureBuilder<List<Map<String, String>>>(
                  future: fetchTz(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final tzSuggestions = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: tzSuggestions.any((tz) => tz["id"] == selectedTzId2) ? selectedTzId2 : null,
                      items: tzSuggestions.map((tz) => DropdownMenuItem<String>(
                        value: tz["id"],
                        child: Text(tz["name"] ?? ""),
                      )).toList(),
                      onChanged: (String? newValue) {
                        final selected = tzSuggestions.firstWhere((tz) => tz["id"] == newValue, orElse: () => {});
                        setState(() {
                          selectedTzId2 = selected["id"] ?? "";
                          selectedTzName2 = selected["name"] ?? "";
                          selectedTzValue2 = double.tryParse(selectedTzId2) ?? 0.0;
                          _editedTz2 = selectedTzValue2.toString();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Time Zone",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space buttons apart
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01, // Responsive vertical padding
                    horizontal: MediaQuery.of(context).size.width * 0.04, // Responsive horizontal padding
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromARGB(255, 219, 35, 35),
                  fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                ),
              ),
            ),
            TextButton(
              onPressed: () {
              _person2Name = name2Controller.text;
              isEditing2 = true;
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _editedName2 = name2Controller.text;
                    _editedGender2 = gender2Controller.text;
                    _editedDob2 = dob2Controller.text;
                    _editedCityId2 = cityId2Controller.text;
                    _editedTob2 = convertTo24HourFormat(tob2Controller.text);
                    _editedTz2 = selectedTzValue2.toString();

                  });

                  print('Edited Name: $_editedName2');
                  print('Edited Date of Birth: $_editedDob2');
                  print('Edited City ID: $_editedCityId2');
                  print('Edited Time of Birth: $_editedTob2');
                  print('Edited Time of Birth: $_editedTz2');
                  print('Edited Gender: $_editedGender2');


                  Navigator.of(context).pop();
                }
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01, // Responsive vertical padding
                    horizontal: MediaQuery.of(context).size.width * 0.04, // Responsive horizontal padding
                  ),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  
  Map<String, dynamic> getEditedProfile2() {
    return {
      'name': _editedName2,
      'gender': _editedGender2,
      'dob': _editedDob2,
      'city_id': selectedCityId2,
      'tob': _editedTob2, // Default to an empty string if null
      'tz': selectedTzValue2.toString()
    };
  }
  Widget _buildCitySelectionField({required TextEditingController controller, required bool isProfile2}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.03;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.015,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label for "From"
          Container(
            width: screenWidth * 0.15,
            alignment: Alignment.centerLeft,
            child: Text(
              "From",
              style: TextStyle(
                color: const Color.fromARGB(255, 9, 9, 9),
                fontFamily: 'Inter',
                fontSize: fontSize,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),

          // TextField with Autocomplete for city selection
          Expanded(
            child: SizedBox(
              height: screenHeight * 0.05,
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  // Debounce API call to prevent excessive requests
                  return _debounceFetchCities(textEditingValue.text);
                },
                onSelected: (String selection) {
                  final selected = citySuggestions.firstWhere(
                    (element) =>
                        "${element['city']}, ${element['country']}" ==
                        selection,
                    orElse: () => {}, // Prevents errors if no match is found
                  );

                  setState(() {
                    if (isProfile2) {
                      selectedCity2 = selected["city"] ?? "";
                      selectedCountry2 = selected["country"] ?? "";
                      selectedLng2 = selected["lat"] ?? "0.0"; // Changed from "lng"
                      selectedCityId2 = selected["id"] ?? "";
                    } else {
                      selectedCity = selected["city"] ?? "";
                      selectedCountry = selected["country"] ?? "";
                      selectedLng = selected["lat"] ?? "0.0"; // Changed from "lng"
                      selectedCityId = selected["id"] ?? "";
                    }
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Color(0xFFFF9933), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Color(0xFFFF9933), width: 1.0),
                      ),
                      hintText: "Enter city name",
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(179, 6, 6, 6),
                          fontSize: fontSize),
                    ),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 7, 7, 7),
                      fontSize: fontSize,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
      completer.complete(
          citySuggestions.map((e) => "${e['city']}, ${e['country']}").toList());
    });

    return completer.future;
  }

  Widget _buildTzSelectionField({required TextEditingController controller}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.03;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.015,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label for "Time Zone"
          Container(
            width: screenWidth * 0.15,
            alignment: Alignment.centerLeft,
            child: Text(
              "TZ",
              style: TextStyle(
                color: const Color.fromARGB(255, 4, 4, 4),
                fontFamily: 'Inter',
                fontSize: fontSize,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),

          // TextField with Autocomplete for time zone selection
          Expanded(
            child: SizedBox(
              height: screenHeight * 0.05,
              child: FutureBuilder<List<Map<String, String>>>(
                future: fetchTz(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final List<Map<String, String>> tzSuggestions =
                      snapshot.data!;

                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }

                      return tzSuggestions.map((e) => e['name']!).where((tz) =>
                          tz
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

                        // Extract numeric value from TZ name (e.g., "GMT+5:30" -> 5.5)
                        selectedTzValue = double.tryParse(selectedTzId) ?? 0.0;
                        _editedTz = selectedTzValue
                            .toString(); // Ensure controller is updated
                      });

                      print(
                          "Selected TZ Value: $selectedTzValue"); // Debug output
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color(0xFFFF9933), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Color(0xFFFF9933), width: 1.0),
                          ),
                          hintText: "Select Time Zone",
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(179, 3, 3, 3),
                              fontSize: fontSize),
                        ),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 1, 1, 1),
                          fontSize: fontSize,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
// }
}