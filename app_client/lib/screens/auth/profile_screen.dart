// lib/screens/auth/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isEditing = false;
  File? _profileImageFile; // To hold the selected image file

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      // If we are exiting edit mode without saving, clear any selected image
      if (!_isEditing) {
        _profileImageFile = null;
      }
    });
  }

  // NEW: Method to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce size
      );

      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  // MODIFIED: Method to handle profile update logic
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    // Prepare the text data for the update
    final Map<String, String> updatedData = {
      'firstName': _firstNameController.text,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'username': user.username,
      'role': user.role,
    };

    bool success;
    if (_profileImageFile != null) {
      // If a new image is selected, use the method for multipart upload
      success = await authProvider.updateUserWithProfileImage(
        data: updatedData,
        imagePath: _profileImageFile!.path,
      );
    } else {
      // Otherwise, use the regular update method
      success = await authProvider.updateUser(updatedData);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false; // Exit editing mode
          _profileImageFile = null; // Clear the selected image
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: ${authProvider.errorMessage ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user data found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            // Display the selected local file if it exists, otherwise the network image
                            backgroundImage: _profileImageFile != null
                                ? FileImage(_profileImageFile!)
                                : (user.image != null && user.image!.isNotEmpty
                                          ? NetworkImage(
                                              "http://10.0.2.2:3000${user.image!}",
                                            )
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_profileImageFile == null &&
                                    (user.image == null || user.image!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            GestureDetector(
                              onTap: _pickImage,
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Username: ${user.username}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your first name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _nameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your last name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
