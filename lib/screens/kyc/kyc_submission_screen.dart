import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/app_theme.dart';
import '../../state/supabase_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../models/driver_models.dart';

class KycSubmissionScreen extends ConsumerStatefulWidget {
  const KycSubmissionScreen({super.key});

  @override
  ConsumerState<KycSubmissionScreen> createState() => _KycSubmissionScreenState();
}

class _KycSubmissionScreenState extends ConsumerState<KycSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _aadhaarController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  File? _licenseFile;
  File? _aadhaarFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _licenseController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLicense) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isLicense) {
          _licenseFile = File(pickedFile.path);
        } else {
          _aadhaarFile = File(pickedFile.path);
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_licenseFile == null || _aadhaarFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both License and Aadhaar images.')),
        );
        return;
      }

      setState(() => _isUploading = true);

      try {
        final repo = ref.read(supabaseRepoProvider);
        
        final licenseUrl = await repo.uploadFile(_licenseFile!, 'kyc-docs');
        final aadhaarUrl = await repo.uploadFile(_aadhaarFile!, 'kyc-docs');

        await ref.read(kycSubmitProvider.notifier).submit(
          license: _licenseController.text,
          aadhaar: _aadhaarController.text,
          licenseUrl: licenseUrl,
          aadhaarUrl: aadhaarUrl,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KYC Submitted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycSubmitProvider);
    final driverDetails = ref.watch(driverDetailsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Driver KYC')),
      body: driverDetails.when(
        data: (details) {
          if (details != null && details.status == KycStatus.approved) {
            return const Center(child: Text('Your KYC is already approved!'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (details?.status == KycStatus.rejected)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red[50],
                      child: Text(
                        'Rejected: ${details?.rejectionReason ?? "Please resubmit details"}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(labelText: 'Driving License Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(true),
                    icon: const Icon(Icons.image),
                    label: Text(_licenseFile == null ? 'Upload License Image' : 'License Selected'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aadhaarController,
                    decoration: const InputDecoration(labelText: 'Aadhaar Number'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(false),
                    icon: const Icon(Icons.image),
                    label: Text(_aadhaarFile == null ? 'Upload Aadhaar Image' : 'Aadhaar Selected'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: (kycState.isLoading || _isUploading) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                    ),
                    child: (kycState.isLoading || _isUploading)
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit KYC Details', style: TextStyle(color: Colors.white)),
                  ),
                  if (kycState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Error: ${kycState.error}', style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading status: $e')),
      ),
    );
  }
}
