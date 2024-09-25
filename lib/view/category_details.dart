import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryId;

  const CategoryDetailsScreen({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Category Details', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('categories').doc(categoryId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Category not found'));
          }

          final category = snapshot.data!;
          final imageUrls = List<String>.from(category['images']);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Category Icon',
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                ),
                SizedBox(
                  height: 200,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    elevation: 1,
                      color: Colors.orange,
                      child: Image.network(category['icon'],fit: BoxFit.fill)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Name: ',
                      style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                    ),
                    Text(
                      category['name'],
                      style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Images',
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 1,
                        child: Image.network(imageUrls[index], fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
