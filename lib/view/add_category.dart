import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _categoryIcon;
  List<XFile> _categoryImages = [];
  bool _isLoading = false; // Track the loading state

  Future<void> _pickCategoryIcon() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _categoryIcon = pickedFile;
    });
  }

  Future<void> _pickCategoryImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _categoryImages = pickedFiles ?? [];
    });
  }

  Future<void> _uploadCategory() async {
    if (_categoryIcon == null || _nameController.text.isEmpty || _categoryImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload category icon
      String iconPath = 'categories/icons/${_categoryIcon!.name}';
      await FirebaseStorage.instance
          .ref(iconPath)
          .putFile(File(_categoryIcon!.path));
      String iconUrl = await FirebaseStorage.instance
          .ref(iconPath)
          .getDownloadURL();

      // Upload category images
      List<String> imageUrls = [];
      for (var image in _categoryImages) {
        String imagePath = 'categories/images/${image.name}';
        await FirebaseStorage.instance
            .ref(imagePath)
            .putFile(File(image.path));
        String imageUrl = await FirebaseStorage.instance
            .ref(imagePath)
            .getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Create a new category document
      DocumentReference categoryDoc = await FirebaseFirestore.instance.collection('categories').add({
        'name': _nameController.text,
        'icon': iconUrl,
        'images': imageUrls,
      });

      // Get the category ID
      String categoryId = categoryDoc.id;

      // Update the category document with the ID
      await categoryDoc.update({'id': categoryId});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully')),
      );

      // Clear fields after successful upload
      setState(() {
        _categoryIcon = null;
        _categoryImages = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Category', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber)) // Show loading indicator
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickCategoryIcon,
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: Container(
                  height: 150,
                  color: Colors.orange,
                  child: _categoryIcon == null
                      ? const Center(child: Text('Pick Category Icon'))
                      : Image.file(File(_categoryIcon!.path)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              cursorColor: Colors.orangeAccent,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickCategoryImages,
              child: Card(
                color: Colors.orange,
                child: Container(
                  height: 60,
                  child: const Center(child: Text('Pick Category Images', style: TextStyle(color: Colors.white))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _categoryImages.length,
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    elevation: 1,
                    child: Image.file(File(_categoryImages[index].path), fit: BoxFit.cover),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.orange)),
              onPressed: _uploadCategory,
              child: const Text('Add Category', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
