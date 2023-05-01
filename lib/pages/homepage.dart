import 'package:corganizer/pages/home/homechat.dart';
import 'package:corganizer/pages/home/homedocs.dart';
import 'package:corganizer/pages/home/homenotes.dart';
import 'package:corganizer/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  final String? name;
  final String? email;
  final String? photoUrl;

  const HomePage({Key? key, this.name, this.email, this.photoUrl, required String url, required String did, required String type})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  static List<Widget> _widgetOptions = <Widget>[
    HomeChat(),
    HomeNotes(),
    HomeDocs(
      url: '', did: '', type: '',
    ),
  ];
  late AnimationController _animationController;
  late Animation<Offset> _rightSlideAnimation;
  bool _isRightPanelOpened = false;

  void _toggleRightPanel() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      _isRightPanelOpened = !_isRightPanelOpened;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _switchAccount() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  void _handleTap() {
    if (_isRightPanelOpened) {
      _toggleRightPanel();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rightSlideAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? name = user?.displayName;
    String? email = user?.email;
    String? photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Corganizer",
          style: TextStyle(
            fontSize: 35.0,
            fontFamily: "lato",
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        elevation: 0.0,
        backgroundColor: const Color(0xff070706),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            iconSize: 30,
          ),
          IconButton(
            onPressed: _toggleRightPanel,
            icon: CircleAvatar(
              backgroundImage: NetworkImage(photoUrl!),
              radius: 40,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name!),
              accountEmail: Text(email!),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                // TODO: navigate to settings page
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          GestureDetector(
            onTap: _handleTap,
            child: SlideTransition(
              position: _rightSlideAnimation,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.85,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      SizedBox(height: 16),
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 280),
                      ElevatedButton(
                        onPressed: () async {
                          await _signOut();
                          user = null;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text('Logout', style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () async {
                          await _switchAccount();
                          user = null;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text('Switch Account',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Docs',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        iconSize: 35,
      ),
    );
  }
}
