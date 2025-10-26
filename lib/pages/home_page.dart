import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: NavigationDrawerWidget(),
      backgroundColor: MyColors.white,
      body: SafeArea(
        //Leading
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
                    builder: (context) {
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
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
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

              //SEARCH BAR
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: MyColors.secondary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: MyColors.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        cursorColor: MyColors.secondary,
                        decoration: InputDecoration(
                          hintText: 'Cari sesuatu...',
                          hintStyle: TextStyle(
                            color: MyColors.secondary.withOpacity(0.7),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      //NAVIGASI BAWAH MENGGUNAKAN PUB.dev
      bottomNavigationBar: CircleNavBar(
        onTap: null,
        height: 60,
        circleWidth: 50,
        circleColor: MyColors.secondary,
        activeIndex: 1,
        activeIcons: [
          Icon(Icons.home, color: MyColors.background),
          Icon(Icons.qr_code, color: MyColors.white),
          Icon(Icons.home_repair_service, color: MyColors.background),
        ],
        inactiveIcons: [
          Icon(Icons.home, color: MyColors.background),
          Icon(Icons.qr_code, color: MyColors.secondary),
          Icon(Icons.home_repair_service, color: MyColors.background),
        ],
        color: MyColors.secondary,
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        shadowColor: MyColors.tertiary,
        circleShadowColor: MyColors.tertiary,
      ),
    );
  }
}
