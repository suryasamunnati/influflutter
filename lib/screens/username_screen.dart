import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_input_field.dart';

class UsernameScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String accessToken;

  const UsernameScreen({
    super.key,
    required this.userData,
    required this.accessToken,
  });

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = false;
  String _availabilityMessage = '';

  @override
  void initState() {
    super.initState();
    // Set the access token in the API service
    _apiService.setAccessToken(widget.accessToken);

    // Pre-fill username if it exists in userData
    if (widget.userData.containsKey('username')) {
      _usernameController.text = widget.userData['username'] ?? '';
      _checkUsernameAvailability();
    }

    // Add listener to check username availability on every change
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    super.dispose();
  }

  // Debounce mechanism to avoid too many API calls
  DateTime? _lastChangeTime;
  void _onUsernameChanged() {
    final now = DateTime.now();
    _lastChangeTime = now;

    // Don't check empty usernames
    if (_usernameController.text.isEmpty) {
      setState(() {
        _isUsernameAvailable = false;
        _availabilityMessage = '';
      });
      return;
    }

    // Wait a short time before checking to avoid API spam
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastChangeTime == now) {
        _checkUsernameAvailability();
      }
    });
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isCheckingUsername = true;
      _availabilityMessage = 'Checking username...';
    });

    try {
      final response = await _apiService.checkUsername(username);
      if (!mounted) return;

      setState(() {
        _isUsernameAvailable = response['available'] ?? false;
        _availabilityMessage =
            response['message'] ??
            (_isUsernameAvailable
                ? 'Username is available'
                : 'Username is not available');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUsernameAvailable = false;
        _availabilityMessage = 'Error checking username';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
        });
      }
    }
  }

  // Replace the existing _handleSaveUsername method with this implementation
  VoidCallback? get _getSaveUsernameCallback {
    if (!_isUsernameAvailable) return null;
    return () {
      _saveUsername();
    };
  }

  Future<void> _saveUsername() async {
    if (!_isUsernameAvailable) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the request body with the username
      final Map<String, dynamic> requestBody = {
        "username": _usernameController.text.trim(),
      };

      // Call the API to update the profile
      final response = await _apiService.updateProfile(requestBody);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Username updated successfully'),
        ),
      );

      // Navigate to the home screen with updated user data
      // In the _saveUsername() method
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => HomeScreen(
                // Make sure we have valid user data by merging the response with existing data
                userData:
                    response['user'] != null
                        ? response['user']
                        : {
                          ...widget.userData,
                          'username': _usernameController.text.trim(),
                        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create your Username",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This will be your public identity on Influ",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Username input field with prefix
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Username",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "influ.in/@",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "yourusername",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Username availability message
              if (_availabilityMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      if (_isCheckingUsername)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(
                          _isUsernameAvailable
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color:
                              _isUsernameAvailable ? Colors.green : Colors.red,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _availabilityMessage,
                        style: TextStyle(
                          color:
                              _isUsernameAvailable ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Save button
              CustomButton(
                text: "Save & Continue",
                onPressed:
                    _isUsernameAvailable
                        ? () {
                          _saveUsername();
                        }
                        : () {}, // Provide empty function instead of null
                isLoading: _isLoading,
                backgroundColor:
                    _isUsernameAvailable
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                textColor: Colors.black,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
