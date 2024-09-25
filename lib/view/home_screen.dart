import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uor_find_manager/view/add_category.dart';
import 'package:uor_find_manager/view/view_all_category.dart';

import 'add_sub_category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(Icons.warning_rounded,size: 44,color: Color(0xffE80000)),
              backgroundColor: Colors.orangeAccent,
              title: const Text('Do You Want to Exit the App',style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  child: const Text('No',style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Yes',style: TextStyle(color: Colors.white70)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                ),
              ],
            );
          },
        );

        return shouldPop ?? false; // Prevent pop if shouldPop is null
      },


      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('Home Screen',style: TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddCategoryScreen()));
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                      child: Column(
                        children: [
                          Icon(Icons.category_rounded,
                              size: 40, color: Colors.tealAccent),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Add Category',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'List your new  category name and photos here.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddSubCategoryScreen()));
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                      child: Column(
                        children: [
                          Icon(Icons.category_rounded,
                              size: 40, color: Colors.tealAccent),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Add Sub Category',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'List your sub category name and photos here.',
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewAllCategoryScreen()));
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 4,
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                      child: Column(
                        children: [
                          Icon(Icons.view_list_rounded, size: 40, color: Colors.tealAccent),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'View All Category',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'View all category and the photos.',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
