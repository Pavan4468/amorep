import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home1.dart'; // WelcomePage
import 'ECommercePage.dart'; // EcommerceApp
import 'ProfilePage.dart'; // ProfilePage
import 'VideosPage.dart'; // VideosPage
import 'Humanity.dart'; // HumanityApp
import 'SearchPage.dart'; // SearchPage
import 'LearnVideo.dart'; // LearnVideoPage
import 'StopDrugs.dart'; // StopDrugsPage
import 'user_list_screen.dart';
import 'upload.dart';

import 'events_page.dart';
import 'posts.dart'; // PostsPage
import 'user_liked_posts_page.dart'; // New page for user-liked posts

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Pages for each section
  final List<Widget> _widgetOptions = <Widget>[
     VideoScreen(),
    const PostsPage(),
    const ReelsPage(),
    const EShoppingHomePage(),
    const ProfilePage(),
  ];

  // Function to handle navigation between pages
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to navigate to other drawer options
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'AMO',
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.black,
            elevation: 10.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          body: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AMO',
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.comment, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  UserLikedPostsPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 10.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[100],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.search, color: Colors.grey[800]),
                title: const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context, const SearchTab());
                },
                tileColor: Colors.white,
                hoverColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
              ListTile(
                leading: Icon(Icons.volunteer_activism, color: Colors.grey[800]),
                title: const Text(
                  'Humanity',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context,  HumanityApp());
                },
                tileColor: Colors.white,
                hoverColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: Colors.grey[800]),
                title: const Text(
                  'Learn Video',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context, const LearnVideoPage());
                },
                tileColor: Colors.white,
                hoverColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
              ListTile(
                leading: Icon(Icons.image, color: Colors.grey[800]),
                title: const Text(
                  'Upload/advertise',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context, const UploadPage());
                },
                tileColor: Colors.white,
                hoverColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
              ListTile(
                leading: Icon(Icons.event, color: Colors.grey[800]),
                title: const Text(
                  'Events',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context, const EventsPage());
                },
                tileColor: Colors.white,
                hoverColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
              ListTile(
                leading: Icon(Icons.no_drinks, color: Colors.grey[800]),
                title: const Text(
                  'Stop Drugs',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context,  StopDrugsPage());
                },
                tileColor: Colors.white,
                hoverColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
            ],
          ),
        ),
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: _onItemTapped,
        height: 60.0,
        color: Colors.black,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.post_add, size: 30, color: Colors.white),
          Icon(Icons.video_library, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}