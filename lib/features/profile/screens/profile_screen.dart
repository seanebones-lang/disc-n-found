import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/analytics_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _favoriteDiscsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _favoriteDiscsController.dispose();
    super.dispose();
  }

  void _loadProfileData(dynamic user) {
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _locationController.text = user.location ?? '';
      _favoriteDiscsController.text = user.favoriteDiscs ?? '';
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      String? photoUrl = currentUser.photoUrl;

      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('${AppConstants.profilesPath}/${currentUser.uid}');
        await ref.putFile(_imageFile!);
        photoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .update({
        'displayName': _nameController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'favoriteDiscs': _favoriteDiscsController.text.trim().isEmpty
            ? null
            : _favoriteDiscsController.text.trim(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      setState(() => _isEditing = false);
      await AnalyticsService.logProfileUpdate();
      ref.invalidate(currentUserProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
                userAsync.whenData(_loadProfileData);
              },
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          if (!_isEditing) {
            _loadProfileData(user);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null) as ImageProvider?,
                          child: _imageFile == null && user.photoUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        if (_isEditing)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.camera_alt, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (_isEditing && (value == null || value.trim().isEmpty)) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: user.email),
                    decoration: const InputDecoration(labelText: 'Email'),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _favoriteDiscsController,
                    decoration: const InputDecoration(labelText: 'Favorite Discs'),
                    enabled: _isEditing,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star),
                      title: Text('Subscription: ${user.subscriptionTier.toUpperCase()}'),
                      subtitle: const Text('Upgrade for premium features'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _handleSignOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
