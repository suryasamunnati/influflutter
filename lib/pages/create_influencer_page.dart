import 'package:flutter/material.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_input_field.dart';
import 'package:myapp/services/api_service.dart';

class CreateInfluencerPage extends StatefulWidget {
  final String accessToken;

  const CreateInfluencerPage({Key? key, required this.accessToken})
    : super(key: key);

  @override
  State<CreateInfluencerPage> createState() => _CreateInfluencerPageState();
}

class _CreateInfluencerPageState extends State<CreateInfluencerPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  bool _isLoading = false;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.setAccessToken(widget.accessToken);
  }

  String? _validateUrl(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter URL';
    }
    if (!Uri.tryParse(value!)!.isAbsolute) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  Future<void> _createInfluencer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final influencerData = {
        'displayName': _displayNameController.text,
        'bio': _bioController.text,
        'avatarUrl': _avatarUrlController.text,
        'socialLinks': {
          'website': _websiteController.text,
          'instagram': _instagramController.text,
          'youtube': _youtubeController.text,
        },
      };

      final response = await _apiService.createInfluencer(influencerData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Influencer profile created successfully',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Create Influencer Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  label: 'Display Name',
                  controller: _displayNameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter display name';
                    }
                    if ((value?.length ?? 0) < 3) {
                      return 'Display name must be at least 3 characters';
                    }
                    return null;
                  },
                  hintText: 'Enter your display name',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Bio',
                  controller: _bioController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter bio';
                    }
                    if ((value?.length ?? 0) < 10) {
                      return 'Bio must be at least 10 characters';
                    }
                    return null;
                  },
                  hintText: 'Enter your bio',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Avatar URL',
                  controller: _avatarUrlController,
                  validator: _validateUrl,
                  hintText: 'Enter avatar URL',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Website',
                  controller: _websiteController,
                  validator: _validateUrl,
                  hintText: 'Enter website URL',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'Instagram',
                  controller: _instagramController,
                  validator: _validateUrl,
                  hintText: 'Enter Instagram profile URL',
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  label: 'YouTube',
                  controller: _youtubeController,
                  validator: _validateUrl,
                  hintText: 'Enter YouTube channel URL',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Create Influencer Profile',
                  onPressed: _createInfluencer,
                  isLoading: _isLoading,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
