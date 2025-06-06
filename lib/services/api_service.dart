import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://backendapis-1gkk.onrender.com';
  String? _accessToken;

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Set access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/api/auth/send-otp',
        data: {
          'phoneNumber': phoneNumber,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to send OTP');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
  
  // Add new method for verifying OTP
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-otp',
        data: {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to verify OTP');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
  
  // Add new method for updating user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      // Ensure token is in headers
      if (_accessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
      }
      
      final response = await _dio.put(
        '/api/users/me',
        data: userData,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
  
  // Add new method for checking username availability
  Future<Map<String, dynamic>> checkUsername(String username) async {
    try {
      // Ensure token is in headers
      if (_accessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
      }
      
      final response = await _dio.post(
        '/api/auth/check-username',
        data: {
          "username": username,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to check username');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
  
  // Add store creation method
  Future<Map<String, dynamic>> createStore(Map<String, dynamic> storeData) async {
    try {
      // Ensure token is in headers
       if (_accessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
      }

      final response = await _dio.post(
        '/api/store',
        data: storeData,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create store');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
  // Add tutor creation method
  Future<Map<String, dynamic>> createTutor(Map<String, dynamic> tutorData) async {
    try {
      // Ensure token is in headers
      if (_accessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
      }

      final response = await _dio.post(
        '/api/tutor',
        data: tutorData,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create tutor profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
  // Add influencer creation method
  Future<Map<String, dynamic>> createInfluencer(Map<String, dynamic> influencerData) async {
    try {
      // Ensure token is in headers
      if (_accessToken != null) {
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
      }

      final response = await _dio.post(
        '/api/influencer',
        data: influencerData,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create influencer profile');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}