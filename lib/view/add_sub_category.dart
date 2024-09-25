import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddSubCategoryScreen extends StatefulWidget {
  const AddSubCategoryScreen({super.key});

  @override
  State<AddSubCategoryScreen> createState() => _AddSubCategoryScreenState();
}

class _AddSubCategoryScreenState extends State<AddSubCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _subCategoryIcon;
  List<XFile> _subCategoryImages = [];
  bool _isLoading = false; // Track the loading state
  String? _selectedCategoryId;
  List<DropdownMenuItem<String>> _categories = [];

  Future<void> _pickSubCategoryIcon() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _subCategoryIcon = pickedFile;
    });
  }

  Future<void> _pickSubCategoryImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _subCategoryImages = pickedFiles ?? [];
    });
  }

  Future<void> _uploadSubCategory() async {
    if (_subCategoryIcon == null ||
        _nameController.text.isEmpty ||
        _subCategoryImages.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload subcategory icon
      String iconPath =
          'categories/subcategories/icons/${_subCategoryIcon!.name}';
      await FirebaseStorage.instance
          .ref(iconPath)
          .putFile(File(_subCategoryIcon!.path));
      String iconUrl =
          await FirebaseStorage.instance.ref(iconPath).getDownloadURL();

      // Upload subcategory images
      List<String> imageUrls = [];
      for (var image in _subCategoryImages) {
        String imagePath = 'categories/subcategories/images/${image.name}';
        await FirebaseStorage.instance.ref(imagePath).putFile(File(image.path));
        String imageUrl =
            await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Get the selected category document
      DocumentReference categoryDoc = FirebaseFirestore.instance
          .collection('categories')
          .doc(_selectedCategoryId);

      // Add the subcategory to the selected category
      await categoryDoc.collection('subcategories').add({
        'name': _nameController.text,
        'icon': iconUrl,
        'images': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subcategory added successfully')),
      );

      // Clear fields after successful upload
      setState(() {
        _subCategoryIcon = null;
        _subCategoryImages = [];
        _nameController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    List<DropdownMenuItem<String>> categories = [];
    querySnapshot.docs.forEach((doc) {
      categories.add(DropdownMenuItem(
        child: Text(doc['name']),
        value: doc.id,
      ));
    });
    setState(() {
      _categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Subcategory',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.amber)) // Show loading indicator
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField(
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Colors.orange,
                    decoration:  InputDecoration(
                      labelText: 'Select Category',
                      labelStyle: TextStyle(color: Colors.white),
                      border: const OutlineInputBorder(),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:  const BorderSide(color: Colors.amber)
                      ),
                    ),
                    items: _categories,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickSubCategoryIcon,
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        height: 150,
                        color: Colors.orange,
                        child: _subCategoryIcon == null
                            ? const Center(child: Text('Pick Subcategory Icon'))
                            : Image.file(File(_subCategoryIcon!.path)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Colors.orangeAccent,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Colors.white)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:  const BorderSide(color: Colors.amber)
                        ),
                      labelText: 'Subcategory Name',
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickSubCategoryImages,
                    child: Card(
                      color: Colors.orange,
                      child: Container(
                        height: 60,
                        child: const Center(
                            child: Text('Pick Subcategory Images',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _subCategoryImages.length,
                      itemBuilder: (context, index) {
                        return Card(
                          clipBehavior: Clip.hardEdge,
                          elevation: 1,
                          child: Image.file(
                              File(_subCategoryImages[index].path),
                              fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.orange)),
                    onPressed: _uploadSubCategory,
                    child: const Text('Add Subcategory',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
      ),
    );
  }
}
