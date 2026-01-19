import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/look.dart';
import '../providers/look_provider.dart';
import '../widgets/animated_button.dart';

class AllLooksScreen extends StatefulWidget {
  const AllLooksScreen({super.key});

  @override
  State<AllLooksScreen> createState() => _AllLooksScreenState();
}

class _AllLooksScreenState extends State<AllLooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditDialog(Look look) {
    final nameController = TextEditingController(text: look.name);
    final confidenceController =
        TextEditingController(text: look.confidenceLevel.toString());
    String selectedStyle = look.style;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขลุค'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อชุด'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStyle,
                decoration: const InputDecoration(labelText: 'สไตล์'),
                items: ['Minimal', 'Street', 'Korean', 'Vintage']
                    .map((style) => DropdownMenuItem(
                          value: style,
                          child: Text(style),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedStyle = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confidenceController,
                decoration: const InputDecoration(labelText: 'ความมั่นใจ (1-5)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedLook = look.copyWith(
                name: nameController.text,
                style: selectedStyle,
                confidenceLevel: int.tryParse(confidenceController.text) ?? 3,
              );
              context.read<LookProvider>().updateLook(updatedLook);
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LookProvider>();
    final looks = provider.looks;
    final isDarkMode = provider.isDarkMode;

    return Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'All Looks',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อหรือสไตล์...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  ),
                  onChanged: (value) => provider.setSearchQuery(value),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: provider.availableStyles.map((style) {
                      final isSelected = provider.filterStyle == style;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedButton(
                          onPressed: () => provider.setFilterStyle(style),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : (isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              style,
                              style: TextStyle(
                                color: isSelected ? Colors.white : null,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Grid View
          Expanded(
            child: looks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'ยังไม่มีลุคในคลัง',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'เริ่มต้นเพิ่มลุคแรกของคุณ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: looks.length,
                    onReorder: (oldIndex, newIndex) {
                      provider.reorderLooks(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final look = looks[index];
                      return Dismissible(
                        key: ValueKey(look.id),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerLeft,
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'ลบ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'แก้ไข',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.edit, color: Colors.white, size: 28),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('ยืนยันการลบ'),
                                content:
                                    Text('คุณต้องการลบ \"${look.name}\" หรือไม่?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('ยกเลิก'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('ลบ'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            _showEditDialog(look);
                            return false;
                          }
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            provider.deleteLook(look.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ลบ ${look.name} แล้ว')),
                            );
                          }
                        },
                        child: _buildGridCard(look, isDarkMode),
                      );
                    },
                  ),
          ),
        ],
      );
  }

  Widget _buildGridCard(Look look, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: look.imageBytes != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.memory(
                      look.imageBytes!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.checkroom,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        look.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.drag_handle,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'สไตล์: ${look.style}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < look.confidenceLevel
                          ? Icons.star
                          : Icons.star_border,
                      size: 18,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
