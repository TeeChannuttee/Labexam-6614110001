import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../models/look.dart';
import '../providers/look_provider.dart';
import '../widgets/animated_button.dart';

class AddLookScreen extends StatefulWidget {
  const AddLookScreen({super.key});

  @override
  State<AddLookScreen> createState() => _AddLookScreenState();
}

class _AddLookScreenState extends State<AddLookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _confidenceController = TextEditingController();
  String _selectedStyle = 'Minimal';
  String? _imagePath;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imagePath = image.path;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเลือกรูปภาพได้: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกแหล่งที่มาของรูปภาพ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('แกลเลอรี'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('กล้อง'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveLook() {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null || _imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกรูปภาพ')),
        );
        return;
      }

      final look = Look(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        style: _selectedStyle,
        confidenceLevel: int.parse(_confidenceController.text),
        imagePath: _imagePath,
        imageBytes: _imageBytes,
      );

      context.read<LookProvider>().addLook(look);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เพิ่ม ${look.name} สำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<LookProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Look'),
        leading: AnimatedIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อชุด *',
                  hintText: 'เช่น Casual Weekend',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อชุด';
                  }
                  if (value.length < 2) {
                    return 'ชื่อชุดต้องมีอย่างน้อย 2 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Style dropdown
              DropdownButtonFormField<String>(
                value: _selectedStyle,
                decoration: InputDecoration(
                  labelText: 'สไตล์ *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                ),
                items: ['Minimal', 'Street', 'Korean', 'Vintage']
                    .map((style) => DropdownMenuItem(
                          value: style,
                          child: Text(style),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStyle = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Confidence level
              TextFormField(
                controller: _confidenceController,
                decoration: InputDecoration(
                  labelText: 'ระดับความมั่นใจ (1-5) *',
                  hintText: '1-5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกระดับความมั่นใจ';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 1 || number > 5) {
                    return 'กรุณากรอกตัวเลข 1-5 เท่านั้น';
                  }
                  return null;
                },
              ),
              if (_confidenceController.text.isNotEmpty &&
                  int.tryParse(_confidenceController.text) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < int.parse(_confidenceController.text)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Image picker
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: _imageBytes != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: AnimatedButton(
                            onPressed: () {
                              setState(() {
                                _imagePath = null;
                                _imageBytes = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : InkWell(
                        onTap: _showImageSourceDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'เลือกรูป / ถ่ายรูป',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'แตะเพื่อเลือกรูปภาพ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 32),

              // Save button
              AnimatedButton(
                onPressed: _saveLook,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'บันทึก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
