import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../state/supabase_providers.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  String selectedCategory = '3W';
  String selectedVehicleType = 'Auto Rickshaw';
  
  final _formKey = GlobalKey<FormState>();
  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _maxKgController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _rcBookFile;
  File? _insuranceFile;

  bool _isSubmitting = false;

  final List<Map<String, dynamic>> categories = [
    {'id': '3W', 'icon': Icons.local_taxi, 'label': '3W'},
    {'id': 'Bike', 'icon': Icons.two_wheeler, 'label': 'Bike'},
    {'id': 'Mini', 'icon': Icons.local_shipping, 'label': 'Mini'},
    {'id': 'Pick-up', 'icon': Icons.local_shipping_outlined, 'label': 'Pick-up'},
    {'id': '10 Ft', 'icon': Icons.fire_truck, 'label': '10 Ft'},
    {'id': '14 Ft', 'icon': Icons.fire_truck_outlined, 'label': '14 Ft'},
  ];

  @override
  void dispose() {
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _maxKgController.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerSourceDialog(Function(File) onImageSelected) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFF6600)),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    onImageSelected(File(pickedFile.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFF6600)),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    onImageSelected(File(pickedFile.path));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_rcBookFile == null || _insuranceFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload both RC Book and Insurance')),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      
      try {
        final repo = ref.read(supabaseRepoProvider);
        
        //final rcBookUrl = await repo.uploadFile(_rcBookFile!, 'kyc-docs');
       // final insuranceUrl = await repo.uploadFile(_insuranceFile!, 'kyc-docs');
        
        await ref.read(vehicleSubmitProvider.notifier).addVehicle(
          category: selectedCategory,
          vehicleType: selectedVehicleType,
          registrationNumber: _registrationController.text,
          make: _makeController.text,
          model: _modelController.text,
          year: _yearController.text,
          color: _colorController.text,
          maxKg: _maxKgController.text,
          rcBookUrl: /*rcBookUrl*/"",
          insuranceUrl: /*insuranceUrl*/"",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully')),
          );
          // Refresh vehicles provider so the home screen updates automatically
          ref.invalidate(vehiclesProvider);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Registration Number *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _registrationController,
                hintText: 'e.g., DL 01 AB 1234',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
            
            _buildLabel('Vehicle Category *'),
            const SizedBox(height: 8),
            _buildCategorySelector(),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Auto-rickshaws, E-rickshaws, Pickup Autos - Up to 500 kg',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Vehicle Type *'),
            const SizedBox(height: 8),
            _buildDropdown(),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Make'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _makeController,
                        hintText: 'e.g., Tata',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Model'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _modelController,
                        hintText: 'e.g., Ace',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Year'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _yearController,
                        hintText: '2020',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Color'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _colorController,
                        hintText: 'White',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Max kg *'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _maxKgController,
                        hintText: '500',
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'upload_documents'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildUploadBox(
                          'rc_book'.tr(),
                          'upload_front'.tr(),
                          file: _rcBookFile,
                          onTap: () => _showImagePickerSourceDialog((f) => _rcBookFile = f),
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadBox(
                          'insurance'.tr(),
                          'upload_back'.tr(),
                          file: _insuranceFile,
                          onTap: () => _showImagePickerSourceDialog((f) => _insuranceFile = f),
                          required: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF6600),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Add Vehicle',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    bool hasAsterisk = text.contains('*');
    if (!hasAsterisk) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      );
    }

    List<String> parts = text.split('*');
    return RichText(
      text: TextSpan(
        text: parts[0],
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
        children: const [
          TextSpan(
            text: '*',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFFF6600)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        bool isSelected = selectedCategory == cat['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = cat['id'];
            });
          },
          child: Container(
            width: 75,
            height: 65,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF7F2) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF6600) : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'],
                  color: isSelected ? const Color(0xFFFF6600) : const Color(0xFF9CA3AF),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  cat['label'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFFFF6600) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedVehicleType,
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF1F2937), size: 28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          items: ['Auto Rickshaw', 'E-Rickshaw', 'Pickup'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                selectedVehicleType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildUploadBox(
    String title,
    String subtitle, {
    File? file,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: file != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (file == _rcBookFile) {
                                _rcBookFile = null;
                              } else {
                                _insuranceFile = null;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 2)
                              ],
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: Color(0xFF9CA3AF), size: 28),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;

  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    var dashWidth = 5.0;
    var dashSpace = 5.0;
    var startX = 0.0;
    
    // Draw top line
    while (startX < size.width) {
      var endX = startX + dashWidth;
      if (endX > size.width) endX = size.width;
      canvas.drawLine(Offset(startX, 0), Offset(endX, 0), paint);
      startX += dashWidth + dashSpace;
    }
    
    // Draw right line
    var startY = 0.0;
    while (startY < size.height) {
      var endY = startY + dashWidth;
      if (endY > size.height) endY = size.height;
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, endY), paint);
      startY += dashWidth + dashSpace;
    }
    
    // Draw bottom line
    startX = size.width;
    while (startX > 0) {
      var endX = startX - dashWidth;
      if (endX < 0) endX = 0;
      canvas.drawLine(Offset(startX, size.height), Offset(endX, size.height), paint);
      startX -= dashWidth + dashSpace;
    }
    
    // Draw left line
    startY = size.height;
    while (startY > 0) {
      var endY = startY - dashWidth;
      if (endY < 0) endY = 0;
      canvas.drawLine(Offset(0, startY), Offset(0, endY), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
