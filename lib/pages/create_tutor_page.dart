import 'package:flutter/material.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_input_field.dart';
import 'package:myapp/services/api_service.dart';

class CreateTutorPage extends StatefulWidget {
  final String accessToken;

  const CreateTutorPage({Key? key, required this.accessToken})
    : super(key: key);

  @override
  State<CreateTutorPage> createState() => _CreateTutorPageState();
}

class _CreateTutorPageState extends State<CreateTutorPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final List<String> _expertiseAreas = [];
  final List<String> _languages = [];
  bool _isLoading = false;
  final _apiService = ApiService();

  final _expertiseController = TextEditingController();
  final _languageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService.setAccessToken(widget.accessToken);
  }

  void _addExpertise() {
    final expertise = _expertiseController.text.trim();
    if (expertise.isNotEmpty && !_expertiseAreas.contains(expertise)) {
      setState(() {
        _expertiseAreas.add(expertise);
        _expertiseController.clear();
      });
    }
  }

  void _addLanguage() {
    final language = _languageController.text.trim();
    if (language.isNotEmpty && !_languages.contains(language)) {
      setState(() {
        _languages.add(language);
        _languageController.clear();
      });
    }
  }

  void _removeExpertise(String expertise) {
    setState(() {
      _expertiseAreas.remove(expertise);
    });
  }

  void _removeLanguage(String language) {
    setState(() {
      _languages.remove(language);
    });
  }

  Future<void> _createTutor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expertiseAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one expertise area')),
      );
      return;
    }
    if (_languages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one language')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tutorData = {
        'displayName': _displayNameController.text,
        'bio': _bioController.text,
        'avatarUrl': _avatarUrlController.text,
        'expertiseAreas': _expertiseAreas,
        'languages': _languages,
      };

      final response = await _apiService.createTutor(tutorData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Tutor profile created successfully',
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
    _expertiseController.dispose();
    _languageController.dispose();
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
          'Create Tutor Profile',
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
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter avatar URL';
                    }
                    if (!Uri.tryParse(value!)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                  hintText: 'Enter avatar URL',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        label: 'Expertise Areas',
                        controller: _expertiseController,
                        hintText: 'Add expertise area',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addExpertise,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children:
                      _expertiseAreas
                          .map(
                            (expertise) => Chip(
                              label: Text(expertise),
                              onDeleted: () => _removeExpertise(expertise),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        label: 'Languages',
                        controller: _languageController,
                        hintText: 'Add language',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addLanguage,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children:
                      _languages
                          .map(
                            (language) => Chip(
                              label: Text(language),
                              onDeleted: () => _removeLanguage(language),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Create Tutor Profile',
                  onPressed: _createTutor,
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
