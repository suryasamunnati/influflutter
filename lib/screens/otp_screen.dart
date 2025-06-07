import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/otp_input_field.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String expiresAt;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.expiresAt,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _digit1Controller = TextEditingController();
  final TextEditingController _digit2Controller = TextEditingController();
  final TextEditingController _digit3Controller = TextEditingController();
  final TextEditingController _digit4Controller = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _digit1Controller.dispose();
    _digit2Controller.dispose();
    _digit3Controller.dispose();
    _digit4Controller.dispose();
    super.dispose();
  }

  // Get the complete OTP code
  String get _otpCode {
    return _digit1Controller.text +
        _digit2Controller.text +
        _digit3Controller.text +
        _digit4Controller.text;
  }

  // Verify OTP
  Future<void> _verifyOtp() async {
    if (_otpCode.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.verifyOtp(
        widget.phoneNumber,
        _otpCode,
      );
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'OTP verified successfully'),
        ),
      );

      // Extract user data and tokens
      final userData = response['user'] as Map<String, dynamic>;
      final isNewUser = response['isNewUser'] as bool;
      final accessToken = response['accessToken'] as String;
      final refreshToken = response['refreshToken'] as String;

      // Navigate based on isNewUser flag
      if (isNewUser) {
        // Navigate to registration screen for new users
        // In the _verifyOtp method, when navigating to RegisterScreen:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => RegisterScreen(
                  userData: userData,
                  accessToken: accessToken,
                ),
          ),
        );
      } else {
        // Include the access token in userData
        userData['accessToken'] = accessToken;

        // Navigate to home screen for existing users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: userData),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

  // Resend OTP
  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      final response = await _apiService.sendOtp(widget.phoneNumber);
      if (!mounted) return;

      // Update expiresAt if needed
      // widget.expiresAt = response['expiresAt'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'OTP resent successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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
                "Verify your OTP.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "OTP was sent to",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "+91 ${widget.phoneNumber}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate back to edit phone number
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit, color: Colors.cyan, size: 16),
                    label: const Text(
                      "Change",
                      style: TextStyle(color: Colors.cyan, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OtpInputField(
                    controller: _digit1Controller,
                    autoFocus: true,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                  OtpInputField(
                    controller: _digit2Controller,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                  OtpInputField(
                    controller: _digit3Controller,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                  OtpInputField(
                    controller: _digit4Controller,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Resend OTP button
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _isResending ? null : _resendOtp,
                    icon:
                        _isResending
                            ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.cyan,
                              ),
                            )
                            : const Icon(
                              Icons.refresh,
                              color: Colors.cyan,
                              size: 16,
                            ),
                    label: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Terms and Conditions
              Text(
                "By Creating an account, you adhere to the",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to Terms of Service
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Terms of Service",
                      style: TextStyle(color: Colors.cyan, fontSize: 12),
                    ),
                  ),
                  Text(
                    " and ",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Privacy Policy
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Privacy Policy",
                      style: TextStyle(color: Colors.cyan, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Verify OTP Button
              CustomButton(
                text: "Verify OTP",
                onPressed: _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
