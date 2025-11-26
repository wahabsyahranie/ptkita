import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_bottom_widget.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';
import 'package:flutter_kita/pages/menu_inventory_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _onTapNav(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Buat pages tanpa endDrawer di inner scaffold
    final List<Widget> _pages = [
      // index 0 - halaman utama (tanpa endDrawer di sini)
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wahab Syahranie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (innerCtx) {
                      return Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: MyColors.secondary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.notifications,
                              color: MyColors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            // gunakan scaffoldKey untuk membuka endDrawer root
                            onTap: () {
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                            child: Container(
                              width: 53,
                              height: 53,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/person_image.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SearchBarWidget(),
            ],
          ),
        ),
      ),

      // index 1
      const Center(child: Text('Tab 1 - QR / Middle')),

      // index 2
      const MenuInventoryPage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey, // <--- root scaffold key
        extendBody: true,
        // Pindahkan endDrawer ke sini agar drawer muncul di atas bottomNavigationBar
        endDrawer: const NavigationDrawerWidget(),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: NavigationBottomWidget(
          activeIndex: _currentIndex,
          onTap: _onTapNav,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () => _onTapNav(1),
            backgroundColor: MyColors.secondary,
            elevation: 4,
            child: Icon(Icons.qr_code, color: MyColors.white),
          ),
        ),
      ),
    );
  }
}
