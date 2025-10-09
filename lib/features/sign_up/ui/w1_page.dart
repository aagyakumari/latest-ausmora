import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/CelestialBackgroundPainter.dart';
import 'package:flutter_application_1/components/animated_text.dart';
import 'package:flutter_application_1/features/sign_up/model/user_model.dart';
import 'package:flutter_application_1/features/sign_up/repo/sign_up_repo.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:intl/intl.dart';
// import 'package:video_player/video_player.dart';
import '../../otp/ui/otp.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/components/help_dialog.dart';

class W1Page extends StatefulWidget {
  const W1Page({super.key});

  @override
  _W1PageState createState() => _W1PageState();
}

class _W1PageState extends State<W1Page> with TickerProviderStateMixin {
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tzController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  final SignUpRepo _signUpRepo = SignUpRepo();
  final HiveService _hiveService = HiveService();

  bool _isLoginMode = false;
  bool _isLoading = false;
  String? selectedCity;
  String? selectedCountry;
  String? selectedLng;
  String selectedTzId = '';
  String selectedTzName = '';
  String selectedCityId = '';
  double selectedTzValue = 0.0;
  // String selectedGenderValue = '';
  int _currentStep = 0;
  List<Map<String, String>> citySuggestions = [];

  // late VideoPlayerController _videoController;

  // Debounce function to reduce API calls for city search
  Timer? _debounce;
  Future<List<Map<String, String>>> _debounceFetchCities(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final completer = Completer<List<Map<String, String>>>();

    _debounce = Timer(Duration(milliseconds: 500), () async {
      citySuggestions = await fetchCities(query);
      completer.complete(citySuggestions);
    });

    return completer.future;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _videoController.dispose();  // Always dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/w1_tablet.png', // Add your background image on top
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: CelestialBackground(),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: isTablet
                ? MediaQuery.of(context).size.height *
                    0.4 // Adjust height for tablets
                : MediaQuery.of(context).size.height *
                    0.45, // Adjust height for phones
            child: Center(
              child: FractionallySizedBox(
                widthFactor:
                    isTablet ? 1 : 0.95, // Different width for tablet/phone
                heightFactor:
                    isTablet ? 1 : 0.95, // Different height for tablet/phone
                child: Image.asset(
                  'assets/images/Ausmora.png',
                  fit: BoxFit.contain, // Use 'contain' for better scaling
                ),
              ),
            ),
          ),

// AnimatedTextWidget for displaying text
          Positioned(
            bottom: isTablet
                ? MediaQuery.of(context).size.height *
                    0.55 // Adjust bottom spacing for tablets
                : MediaQuery.of(context).size.height *
                    0.6, // Adjust bottom spacing for phones
            left: 0,
            right: 0,
            child: AnimatedTextWidget(
              texts: const [
                "love",
                "career",
                "friendship",
                "business",
                "education",
                "partnership",
                "marriage"
              ],
              textStyle: TextStyle(
                fontSize: isTablet
                    ? MediaQuery.of(context).size.height *
                        0.025 // Slightly larger font size for tablets
                    : MediaQuery.of(context).size.height *
                        0.02, // Font size for phones
                color: Colors.orange,
                fontWeight: FontWeight.w200,
                fontFamily: 'Inter',
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 50.0 : 16.0,
                vertical: isTablet ? 30.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          (isTablet ? 0.45 : 0.4)),

                  // Show the current step
                  // Show current form field
                  if (!_isLoginMode) _formSteps(context)[_currentStep],
                  if (_isLoginMode) _formSteps(context).last,

                  const SizedBox(height: 16),

// Help button for sign up mode
                  if (!_isLoginMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () {
                            HelpDialog.show(context, [
                              {
                                'title': 'Name',
                                'description':
                                    'Enter your full name as it appears on official documents'
                              },
                              {
                                'title': 'Gender',
                                'description': 'Enter your gender'
                              },
                              {
                                'title': 'Place of Birth',
                                'description':
                                    'Click the dropdown arrow to see popular cities, or type to search for your city'
                              },
                              {
                                'title': 'Time Zone',
                                'description':
                                    'Select your time zone from the dropdown. This helps calculate accurate birth time'
                              },
                              {
                                'title': 'Birth Date',
                                'description':
                                    'Tap to select the exact date you were born'
                              },
                              {
                                'title': 'Birth Time',
                                'description':
                                    'Tap to select the time you were born. Ask your parents if you\'re not sure'
                              },
                              {
                                'title': 'Email',
                                'description':
                                    'Enter a valid email address where you can receive verification codes'
                              },
                            ]);
                          },
                          icon: Icon(Icons.help_outline,
                              color: Color(0xFFFF9933), size: 16),
                          label: Text(
                            'Need help?',
                            style: TextStyle(
                              color: Color(0xFFFF9933),
                              fontFamily: 'Inter',
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ),

// Step buttons for sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left arrow
                      IconButton(
                        icon: Icon(
                          Icons.arrow_left,
                          color: (!_isLoginMode && _currentStep == 0)
                              ? Colors.grey
                              : Colors.white,
                        ),
                        onPressed: (!_isLoginMode && _currentStep == 0)
                            ? null
                            : _previousStep,
                        iconSize: 30.0,
                      ),
                      // Step indicator in the middle
                      if (!_isLoginMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _buildStepIndicator(_formSteps(context).length),
                        ),
                      // Right arrow
                      IconButton(
                        icon: Icon(
                          Icons.arrow_right,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_isLoginMode) {
                            _loginUser(context, _isLoginMode);
                          } else {
                            if (_currentStep ==
                                _formSteps(context).length - 1) {
                              _signupAndNavigateToOTP(context, _isLoginMode);
                            } else {
                              _nextStep();
                            }
                          }
                        },
                        iconSize: 30.0,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: _toggleLoginMode,
                    child: Text(
                      _isLoginMode
                          ? 'Switch to Sign Up'
                          : 'I already have an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 225, 176, 137),
                        fontFamily: 'Inter',
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int totalSteps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == _currentStep;
        final isComplete = index < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 18.0,
          height: 18.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (isActive || isComplete) ? const Color(0xFFFF9933) : Colors.grey,
              width: 1.0,
            ),
            color: Colors.transparent,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: (isActive || isComplete) ? const Color(0xFFFF9933) : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _formSteps(BuildContext context) => [
        _buildTextField(
          controller: _nameController,
          hintText: 'Enter your full name',
        ),
        _buildCitySelectionField(controller: _locationController),
        _buildTzSelectionField(controller: _tzController),
        _buildTextField(
          controller: _birthDateController,
          hintText: 'Select your birth date',
          onTap: () => _selectDate(context),
        ),

        _buildTextField(
          controller: _birthTimeController,
          hintText: 'Select your birth time',
          onTap: () => _selectTime(context),
        ),
         _buildGenderSelectionField(controller: _genderController),
        // _buildTextField(
        //   controller: _genderController,
        //   hintText: 'Enter your gender',
        // ),
        _buildTextField(
          controller: _emailController,
          hintText: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
        ),
      ];

  void _nextStep() {
    if (_currentStep < _formSteps(context).length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Final step reached - submit or navigate
      _signupAndNavigateToOTP(context, _isLoginMode);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    GestureTapCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? tooltipText,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalPadding = screenWidth * 0.05;
    double verticalPadding = screenHeight * 0.015;
    double fontSize = screenWidth * 0.03;
    String? nameError;

    bool isNameField = hintText.toLowerCase().contains('name');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          // Only show the input field centered, no step arrows here
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: TextField(
                        controller: controller,
                        onTap: onTap,
                        readOnly: onTap != null,
                        keyboardType: keyboardType,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF9933),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF9933),
                              width: 1.0,
                            ),
                          ),
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Inter',
                            fontSize: fontSize,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: fontSize,
                        ),
                        onChanged: isNameField
                            ? (value) {
                                if (value.trim().isNotEmpty &&
                                    double.tryParse(value.trim()) != null) {
                                  setState(() {
                                    nameError = 'Name cannot be numeric.';
                                  });
                                } else {
                                  setState(() {
                                    nameError = null;
                                  });
                                }
                              }
                            : null,
                      ),
                    ),
                    if (isNameField && nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          nameError!,
                          style: TextStyle(
                              color: Colors.red, fontSize: fontSize * 0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCitySelectionField({required TextEditingController controller}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.03;
    String? cityError;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.015,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.05,
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.01,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFFF9933), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color(0xFFFF9933), width: 1.0),
                    ),
                    hintText: "Enter city name",
                    hintStyle: TextStyle(color: Colors.white70, fontSize: fontSize),
                  ),
                  onChanged: (value) async {
                    if (value.trim().isNotEmpty && double.tryParse(value.trim()) != null) {
                      setState(() {
                        cityError = 'City cannot be numeric.';
                      });
                    } else {
                      setState(() {
                        cityError = null;
                      });
                    }
                    if (value.isNotEmpty) {
                      citySuggestions = await _debounceFetchCities(value);
                      setState(() {});
                    } else {
                      citySuggestions.clear();
                      setState(() {});
                    }
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && double.tryParse(value.trim()) != null) {
                      setState(() {
                        cityError = 'City cannot be numeric.';
                      });
                    } else {
                      setState(() {
                        cityError = null;
                      });
                    }
                  },
                ),
              ),
              if (cityError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    cityError!,
                    style: TextStyle(color: Colors.red, fontSize: fontSize * 0.9),
                  ),
                ),
              if (citySuggestions.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Color(0xFFFF9933), width: 1.0),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: citySuggestions.length,
                      itemBuilder: (context, index) {
                        final city = citySuggestions[index];
                        return ListTile(
                          title: Text(
                            "${city['city']}, ${city['country']}",
                            style: TextStyle(color: Colors.white, fontSize: fontSize * 0.9),
                          ),
                          onTap: () {
                            setState(() {
                              selectedCity = city["city"] ?? "";
                              selectedCountry = city["country"] ?? "";
                              selectedLng = city["lat"] ?? "0.0";
                              selectedCityId = city["id"] ?? "";
                              controller.text = "${city['city']}, ${city['country']}";
                              citySuggestions.clear();
                              cityError = null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTzSelectionField({required TextEditingController controller}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.03;

    List<Map<String, String>> tzSuggestions = [];
    bool showDropdown = false;
    bool isLoading = false;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.015,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          Future<void> openDropdown() async {
            setState(() {
              isLoading = true;
            });
            tzSuggestions = await fetchTz();
            setState(() {
              showDropdown = true;
              isLoading = false;
            });
          }

          void closeDropdown() {
            setState(() {
              showDropdown = false;
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  if (!showDropdown) {
                    await openDropdown();
                  } else {
                    closeDropdown();
                  }
                },
                child: SizedBox(
                  height: screenHeight * 0.05,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: showDropdown ? Color(0xFFFF9933) : Colors.grey,
                        width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            selectedTzName.isNotEmpty
                                ? selectedTzName
                                : 'Select Time Zone',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedTzName.isNotEmpty
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Color(0xFFFF9933)),
                      ],
                    ),
                  ),
                ),
              ),
              if (showDropdown)
                Container(
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Color(0xFFFF9933), width: 1.0),
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9933)),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tzSuggestions.length,
                            itemBuilder: (context, index) {
                              final tz = tzSuggestions[index];
                              return ListTile(
                                title: Text(
                                  tz['name'] ?? '',
                                  style: TextStyle(color: Colors.white, fontSize: fontSize * 0.9),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedTzId = tz["id"] ?? "";
                                    selectedTzName = tz["name"] ?? "";
                                    selectedTzValue = double.tryParse(selectedTzId) ?? 0.0;
                                    _tzController.text = selectedTzValue.toString();
                                    showDropdown = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }

Widget _buildGenderSelectionField({required TextEditingController controller}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  double fontSize = screenWidth * 0.03;

  List<String> genderOptions = ["Male", "Female"];
  bool showDropdown = false;

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: screenWidth * 0.05,
      vertical: screenHeight * 0.015,
    ),
    child: StatefulBuilder(
      builder: (context, setState) {
        void openDropdown() {
          setState(() {
            showDropdown = true;
          });
        }

        void closeDropdown() {
          setState(() {
            showDropdown = false;
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (!showDropdown) {
                  openDropdown();
                } else {
                  closeDropdown();
                }
              },
              child: SizedBox(
                height: screenHeight * 0.05,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: showDropdown ? Color(0xFFFF9933) : Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          controller.text.isNotEmpty
                              ? controller.text
                              : 'Select Gender',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.text.isNotEmpty
                                ? Colors.white
                                : Colors.white70,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Color(0xFFFF9933)),
                    ],
                  ),
                ),
              ),
            ),
            if (showDropdown)
              Container(
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Color(0xFFFF9933), width: 1.0),
                ),
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: genderOptions.length,
                    itemBuilder: (context, index) {
                      final gender = genderOptions[index];
                      return ListTile(
                        title: Text(
                          gender,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize * 0.9,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            controller.text = gender;
                            showDropdown = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

  // Method to toggle between signup and login modes
  void _toggleLoginMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _nameController.clear();
      _birthDateController.clear();
      _birthTimeController.clear();
      _locationController.clear();
      _emailController.clear();
      _tzController.clear();
    });
  }

  void _loginUser(BuildContext context, bool isLoginMode) async {
    if (_emailController.text.isNotEmpty) {
      String email = _emailController.text;

      setState(() {
        _isLoading = true;
      });

      try {
        bool isLoggedIn = await _signUpRepo.login(email);

        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpOverlay(email: email, isLoginMode: isLoginMode)),
          );
        } else {
          _showSnackBar(context, 'Email not registered. Please sign up.');
        }
      } catch (e) {
        print('Login error: $e');
        _showSnackBar(context, 'An error occurred during login.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showSnackBar(context, 'Please enter your email.');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _birthTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

// String getTimeZoneFromLongitude(String longitude, List<dynamic> timeZones) {
//   double lng = double.parse(longitude);
//   double closestDiff = double.infinity;
//   String closestTimeZone = "GMT+0:00"; // Default

//   for (var tz in timeZones) {
//     double tzLng = double.parse(tz["id"]); // Convert GMT ID to number
//     double diff = (tzLng - lng).abs(); // Calculate absolute difference

//     if (diff < closestDiff) {
//       closestDiff = diff;
//       closestTimeZone = tz["name"]; // Store the closest matching timezone
//     }
//   }

//   return closestTimeZone;
// }

//   Future<void> fetchTimeZone(String selectedLng) async {
//   final url = Uri.parse('$baseApiUrl/Guests/GetGMTTZ');

//   try {
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List<dynamic> timeZones = data["data"]["gmt_tz"];

//       // 🔹 Call function to get correct GMT based on longitude
//       String correctTimeZone = getTimeZoneFromLongitude(selectedLng, timeZones);

//       setState(() {
//         selectedTimeZone = correctTimeZone;
//         print("Selected Timezone: $selectedTimeZone");
//       });

//     } else {
//       print("Failed to fetch timezone");
//     }
//   } catch (e) {
//     print("Error fetching timezone: $e");
//   }
// }

  void _signupAndNavigateToOTP(BuildContext context, bool isLoginMode) async {
    if (_validateInputs()) {
      UserModel user = UserModel(
          name: _nameController.text,
          email: _emailController.text,
          cityId: selectedCityId,
          dob: _birthDateController.text,
          tob: _birthTimeController.text,
          tz: selectedTzValue,
          gender: _genderController.text // Pass the correct timezone

          );

      setState(() {
        _isLoading = true;
      });

      try {
        bool isSignedUp = await _signUpRepo.signUp(user);
        if (isSignedUp) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpOverlay(email: user.email, isLoginMode: isLoginMode)),
          );
        } else {
          _showSnackBar(
              context, 'This email is already registered! Try logging in.');
        }
      } catch (e) {
        print('Signup error: $e');
        _showSnackBar(context, 'An error occurred during signup.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    List<String> errors = [];

    if (_nameController.text.isEmpty) {
      errors.add('Please enter your name');
    } else if (_nameController.text.length < 2) {
      errors.add('Name must be at least 2 characters long');
    } else if (double.tryParse(_nameController.text.trim()) != null) {
      errors.add('Name cannot be numeric.');
    }

    if (_genderController.text.isEmpty) {
      errors.add('Please select your gender');
    } 
    // else {
    //   final gender = _genderController.text.trim().toLowerCase();
    //   if (gender != 'male' && gender != 'female') {
    //     errors.add('Gender must be either "male" or "female"');
    //   }
    // }

    if (selectedCityId.isEmpty || selectedCityId == 'null') {
      errors.add('Please select your place of birth');
    } else if (double.tryParse(_locationController.text.trim()) != null) {
      errors.add('City cannot be numeric.');
    }

    if (selectedTzValue == 0.0) {
      errors.add('Please select your time zone');
    }

    if (_birthDateController.text.isEmpty) {
      errors.add('Please select your birth date');
    }

    if (_birthTimeController.text.isEmpty) {
      errors.add('Please select your birth time');
    }

    if (_emailController.text.isEmpty) {
      errors.add('Please enter your email address');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      errors.add('Please enter a valid email address');
    }

    if (errors.isNotEmpty) {
      _showValidationErrors(errors);
      return false;
    }

    return true;
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Please fix the following:',
          style: TextStyle(color: Color(0xFFFF9933)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map((error) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text(error)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
