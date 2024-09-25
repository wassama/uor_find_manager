import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_details.dart';
import 'edit_category.dart';

class ViewAllCategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Categories', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color:Colors.orange));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return SwipeToDeleteWidget(
                category: category,
              );
            },
          );
        },
      ),
    );
  }
}

class SwipeToDeleteWidget extends StatefulWidget {
  final QueryDocumentSnapshot category;

  const SwipeToDeleteWidget({required this.category});

  @override
  _SwipeToDeleteWidgetState createState() => _SwipeToDeleteWidgetState();
}

class _SwipeToDeleteWidgetState extends State<SwipeToDeleteWidget> {
  double _swipeOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _swipeOffset += details.delta.dx;
          if (_swipeOffset > 0) _swipeOffset = 0; // Prevent swiping right
        });
      },
      onHorizontalDragEnd: (details) {
        if (_swipeOffset < -100) {
          setState(() {
            _swipeOffset = -100; // Keep the delete icon visible when swiped halfway
          });
        } else {
          setState(() {
            _swipeOffset = 0;
          });
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('categories').doc(widget.category.id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category deleted')),
                  );
                },
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: Card(
              color: Colors.orange,
              child: ListTile(
                title: Text(widget.category['name'],style: TextStyle(color: Colors.white)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      style: const ButtonStyle(shape: MaterialStatePropertyAll(CircleBorder(side: BorderSide(color: Colors.white)))),
                      icon: const Icon(Icons.visibility,color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetailsScreen(categoryId: widget.category.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      style: ButtonStyle(shape: MaterialStatePropertyAll(CircleBorder(side: BorderSide(color: Colors.white)))),
                      icon: const Icon(Icons.edit,color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCategoryScreen(categoryId: widget.category.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
