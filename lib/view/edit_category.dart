import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditCategoryScreen extends StatefulWidget {
  final String categoryId;

  const EditCategoryScreen({required this.categoryId});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<String> _categoryImages = [];
  List<File> _newImages = [];
  File? _newIcon;
  String? _categoryIcon;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
  }

  Future<void> _fetchCategoryDetails() async {
    final category = await FirebaseFirestore.instance.collection('categories').doc(widget.categoryId).get();

    if (category.exists) {
      setState(() {
        _nameController.text = category['name'];
        _categoryImages = List<String>.from(category['images']);
        _categoryIcon = category['icon'];
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage({required bool isIcon}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isIcon) {
          _newIcon = File(pickedFile.path);
        } else {
          _newImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _removeImage(String imageUrl) async {
    setState(() {
      _categoryImages.remove(imageUrl);
    });

    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();
    await FirebaseFirestore.instance.collection('categories').doc(widget.categoryId).update({
      'images': FieldValue.arrayRemove([imageUrl]),
    });
  }

  Future<void> _saveCategory() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload new icon if available
      if (_newIcon != null) {
        String iconPath = 'categories/icons/${_newIcon!.path.split('/').last}';
        await FirebaseStorage.instance.ref(iconPath).putFile(_newIcon!);
        _categoryIcon = await FirebaseStorage.instance.ref(iconPath).getDownloadURL();
      }

      // Upload new images if available
      List<String> newImageUrls = [];
      for (var file in _newImages) {
        String imagePath = 'categories/images/${file.path.split('/').last}';
        await FirebaseStorage.instance.ref(imagePath).putFile(file);
        String imageUrl = await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
        newImageUrls.add(imageUrl);
      }

      _categoryImages.addAll(newImageUrls);

      await FirebaseFirestore.instance.collection('categories').doc(widget.categoryId).update({
        'name': _nameController.text,
        'icon': _categoryIcon,
        'images': FieldValue.arrayUnion(newImageUrls),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Category', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              onTap: () => _pickImage(isIcon: true),
              child: Stack(
                children: [
                  Card(
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      height: 150,
                      color: Colors.orange,
                      child: _newIcon == null
                          ? (_categoryIcon == null
                          ? const Center(child: Text('Pick Category Icon', style: TextStyle(color: Colors.white)))
                          : Image.network(_categoryIcon!, fit: BoxFit.cover))
                          : Image.file(_newIcon!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 30,
                      left: 30,
                      right: 30,
                      bottom: 30,
                      child: Icon(CupertinoIcons.camera_fill,color: Colors.orange,size: 44,))
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickImage(isIcon: false),
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: Container(
                  height: 50,
                  color: Colors.orange,
                  child: const Center(child: Text('Pick Category Images', style: TextStyle(color: Colors.white))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isUploading
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: _categoryImages.length + _newImages.length,
                itemBuilder: (context, index) {
                  if (index < _categoryImages.length) {
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      elevation: 1,
                      shadowColor: Colors.white,
                      child: Stack(
                        children: [
                          Image.network(_categoryImages[index], fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeImage(_categoryImages[index]),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      elevation: 1,
                      shadowColor: Colors.white,
                      child: Image.file(_newImages[index - _categoryImages.length], fit: BoxFit.cover),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.orange)),
              onPressed: _saveCategory,
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
