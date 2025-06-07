import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/username_screen.dart'; // Add this import
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_input_field.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String accessToken;

  const RegisterScreen({
    super.key,
    required this.userData,
    required this.accessToken,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedGender = 'Male';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Set the access token in the API service
    _apiService.setAccessToken(widget.accessToken);

    // Pre-fill fields if data exists in userData
    if (widget.userData.containsKey('fullName')) {
      _nameController.text = widget.userData['fullName'] ?? '';
    }
    if (widget.userData.containsKey('email')) {
      _emailController.text = widget.userData['email'] ?? '';
    }
    if (widget.userData.containsKey('dateOfBirth')) {
      _dobController.text = widget.userData['dateOfBirth'] ?? '';
    }
    if (widget.userData.containsKey('gender')) {
      _selectedGender = widget.userData['gender'] ?? 'male';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100), // Changed to allow dates far in the future
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF303030),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF202020),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format as DD/MM/YYYY
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _completeRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare the request body
        final Map<String, dynamic> requestBody = {
          "fullName": _nameController.text,
          "email": _emailController.text,
          "dateOfBirth": _dobController.text,
          "gender": _selectedGender,
        };

        // Call the API to update the profile
        final response = await _apiService.updateProfile(requestBody);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Profile updated successfully',
            ),
          ),
        );

        // Navigate to the username screen instead of home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => UsernameScreen(
                  userData: response['user'],
                  accessToken: widget.accessToken,
                ),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Complete Registration",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome to the app!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please complete your profile",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name field
                  CustomInputField(
                    controller: _nameController,
                    label: "Full Name",
                    hintText: "Enter your full name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  CustomInputField(
                    controller: _emailController,
                    label: "Email",
                    hintText: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth field
                  CustomInputField(
                    controller: _dobController,
                    label: "Date of Birth",
                    hintText: "DD/MM/YYYY",
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your date of birth";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text(
                      "Select Date",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender selection
                  const Text(
                    "Gender",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'male',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          Set<MaterialState> states,
                        ) {
                          return Colors.white;
                        }),
                      ),
                      const Text('Male', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'female',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          Set<MaterialState> states,
                        ) {
                          return Colors.white;
                        }),
                      ),
                      const Text(
                        'Female',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'others',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          Set<MaterialState> states,
                        ) {
                          return Colors.white;
                        }),
                      ),
                      const Text(
                        'Others',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  CustomButton(
                    text: "Complete Registration",
                    onPressed: _completeRegistration,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
