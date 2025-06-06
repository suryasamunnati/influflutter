import 'package:flutter/material.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_input_field.dart';
import 'package:myapp/services/api_service.dart';

class CreateStorePage extends StatefulWidget {
  final String accessToken;

  const CreateStorePage({Key? key, required this.accessToken})
    : super(key: key);

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _slugController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoUrlController = TextEditingController();
  bool _isLoading = false;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _apiService.setAccessToken(widget.accessToken);
  }

  Future<void> _createStore() async {
    // Inside _createStore() method, before making the API call
    print('Access Token: ${widget.accessToken}');
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storeData = {
        'storeName': _storeNameController.text,
        'slug': _slugController.text,
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'logoUrl': _logoUrlController.text,
      };

      // Inside _createStore() method, after creating storeData
      print('Store Data: $storeData');
      final response = await _apiService.createStore(storeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Store created successfully'),
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
    _storeNameController.dispose();
    _slugController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
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
          'Create Store',
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
                  label: 'Store Name',
                  controller: _storeNameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter store name';
                    }
                    if ((value?.length ?? 0) < 3) {
                      return 'Store name must be at least 3 characters';
                    }
                    return null;
                  },
                  hintText: 'Enter your store name',
                ),
                SizedBox(height: 16),
                CustomInputField(
                  label: 'Store Slug',
                  controller: _slugController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter store slug';
                    }
                    if ((value?.length ?? 0) < 3) {
                      return 'Slug must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value!)) {
                      return 'Slug can only contain lowercase letters, numbers, and hyphens';
                    }
                    return null;
                  },
                  hintText: 'Enter store slug (e.g., my-awesome-store)',
                ),
                SizedBox(height: 16),
                CustomInputField(
                  label: 'Category',
                  controller: _categoryController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter store category';
                    }
                    if ((value?.length ?? 0) < 3) {
                      return 'Category must be at least 3 characters';
                    }
                    return null;
                  },
                  hintText: 'Enter store category',
                ),
                SizedBox(height: 16),
                CustomInputField(
                  label: 'Description',
                  controller: _descriptionController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter store description';
                    }
                    if ((value?.length ?? 0) < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                  hintText: 'Enter store description',
                ),
                SizedBox(height: 16),
                CustomInputField(
                  label: 'Logo URL',
                  controller: _logoUrlController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter logo URL';
                    }
                    if (!Uri.tryParse(value!)!.isAbsolute ?? true) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                  hintText: 'Enter logo URL',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Create Store',
                  onPressed: _createStore,
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
